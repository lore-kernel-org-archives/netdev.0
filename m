From: Jean-Baptiste <jean-baptiste.note@m4x.org>
Subject: A propos the tcp6_sock slab leak in test9
Date: Sun, 23 Nov 2003 03:03:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031123020306.GA23121@gxaafoot.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I've got a box showing the ipv6_sock
slab leak reported some time ago on
the lkml and forwarded on this list
on the 11th.
The slab count is now around 8600 with just
13 days uptime.

Opening/closing an ftp ipv6 connection
is enough to increase the slab usage by
one, and never see it go back...
In case some investigation can be done
on-site, i can give you full access to
the box that's hooked 24/7 on the internet.
Or you may equally redirect me to some
work in order to track the problem.

I'm running a stock test9 with only
a wlan driver loaded from outside the kernel
tree.

Thanks for your work,
JB
