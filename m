From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e1000 typo?
Date: Wed, 30 Jul 2003 11:24:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102229242@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jason Lunz" <lunz@reflexsecurity.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> is that intentional? I don't think it changes the code 
> behavior, but it doesn't look right.

It's intentional because && stops evaluating if left op is false which
means we would leave Tx cleanup work when there was no Rx work.  

-scott
