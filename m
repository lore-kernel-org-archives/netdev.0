From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [patch] e1000 TSO parameter
Date: Tue, 15 Jul 2003 17:27:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010222917D@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <davidm@hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> TSO disabled:
> 
>  $ modprobe InterruptThrottleRate=0,0,0,0 TSO=0,0,0,0

If you're trying to remove all interrupt moderation, you'll also want to
add these:

RxIntDelay=0,0,0,0 RxAbsIntDelay=0,0,0,0 TxIntDelay=0,0,0,0
TxAbsIntDelay=0,0,0,0

See the app note here for more info:
http://www.intel.com/design/network/applnots/8254x_ap450.htm

-scott
