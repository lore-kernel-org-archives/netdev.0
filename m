From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 0/8] Use SLAB_PANIC when creating critical slab cache
Date: Sun, 14 Nov 2004 12:18:37 -0800
Message-ID: <20041114121837.X2357@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following trivial patches update networking code to use the SLAB_PANIC
flag when creating a critical slab cache instead of doing localized calls
to panic().  This brings networking inline with other core kernel code.

 core/flow.c       |    5 +----
 core/skbuff.c     |    4 +---
 decnet/dn_route.c |    9 +++------
 ipv4/inetpeer.c   |    5 +----
 ipv4/ipmr.c       |    5 +----
 ipv6/ip6_fib.c    |    4 +---
 ipv6/route.c      |    9 +++------
 xfrm/xfrm_input.c |    4 +---
 8 files changed, 12 insertions(+), 33 deletions(-)

thanks,
-chris
