From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] new iproute2
Date: Fri, 13 Aug 2004 17:00:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040813170051.67d79b9d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@znyx.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Okay, here is a new version of iproute2 with your last round of CLS patches
incorporated in.  Note: I fixed up some things that seemed to have changed in
the current version of pkt_cls.h

Also:
	- removed all #ifdef CONFIG_ from the command. 
	- copy of kernel headers is now in iproute2/include/linux so that
	  it will build without matching kernel headers.
	- this reduces the amount of configuration necessary.

I don't want this final until you go over it Jamal, cause I had to rework your
stuff enough that I probably broke it.

See:
	http://developer.osdl.org/dev/iproute2/iproute2-2.6.8-jamal.tgz
