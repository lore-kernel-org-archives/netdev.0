From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: e100 "Ferguson" release
Date: Sat, 2 Aug 2003 21:34:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

New development version:

	http://sf.net/projects/e1000, e100-3.0.0_dev11.tar.gz

Many thanks to JC [jchapman@katalix.com] for exploring the small packet
performance w/ and w/o NAPI.  This version includes one of his
optimization; others may follow, but I wanted to get this goodness out
now.

* added opportunistic fast loop (no udelays) in 
  e100_exec_cmd to wait for previous cmd to be
  accepted before queuing next cmd.  Boost 
  small packet performance.  [jchapman@katalix.com].
* Use correct versions of dev_kfree_skb for depending
  on possible contexts.  [jchapman@katalix.com].
* Added SET_NETDEV_DEV().

Looking for more testing on non-IA archs, power management, cardbus
nics, and WoL.

-scott
