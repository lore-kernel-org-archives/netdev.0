From: Stephen Hemminger <shemminger@osdl.org>
Subject: [announce] iproute2 update
Date: Fri, 30 Jul 2004 15:37:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730153715.453c14cf@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This version supports:
	* changes 'tc' for latest netem queuing discipline 
	* additions to 'ip' to support xfrm
	* more robust configuration (works with older 2.4 systems) to detect
	  xfrm, hfsc, htb, etc.

The versioning scheme is to label the highest version of kernel used.
It should build and run on older systems as well, but obviously can't support stuff your
kernel doesn't have. So if a new feature (like netem scheduler) got added in 2.6.8 kernel,
then you would need the corresponding iproute2 to use it.

Available at:
	http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.8-ss040730.tar.gz
