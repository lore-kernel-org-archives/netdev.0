From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: RE: [patch] e1000 TSO parameter
Date: Tue, 15 Jul 2003 17:41:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16148.40771.167565.322759@napali.hpl.hp.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222917D@orsmsx402.jf.intel.com>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: <davidm@hpl.hp.com>, <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010222917D@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Tue, 15 Jul 2003 17:27:56 -0700, "Feldman, Scott" <scott.feldman@intel.com> said:

  >> TSO disabled:

  >> $ modprobe InterruptThrottleRate=0,0,0,0 TSO=0,0,0,0

  Scott> If you're trying to remove all interrupt moderation, you'll
  Scott> also want to add these:

  Scott> RxIntDelay=0,0,0,0 RxAbsIntDelay=0,0,0,0 TxIntDelay=0,0,0,0
  Scott> TxAbsIntDelay=0,0,0,0

  Scott> See the app note here for more info:
  Scott> http://www.intel.com/design/network/applnots/8254x_ap450.htm

I wasn't aware of that note.  Thanks for the pointer!

	--david
