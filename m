From: Stephen Hemminger <shemminger@osdl.org>
Subject: [announce] iproute2 for 2.6.8 (and 2.4.27)
Date: Mon, 23 Aug 2004 13:53:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823135321.23194fee@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, lartc@mailman.ds9a.nl, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This version supports:
	* changes 'tc' for latest netem
	* hfsc/sc patch from Patrick
	* packet classification action from Jamal
	* copies of critical tc/netlink API headers so the command can be
	  built on older systems. Only auto-configuration left is ATM.

The versioning scheme is to label the highest version of kernel used.
It should build and run on older systems as well, but obviously can't support stuff your
kernel doesn't have. So if a new feature (like netem scheduler) got added in 2.6.8 kernel,
then you would need the corresponding iproute2 to use it.


Available at:
	http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.8-040823.tar.gz
