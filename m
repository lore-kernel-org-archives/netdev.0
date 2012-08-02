From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: route.c cleanup
Date: Thu, 02 Aug 2012 11:23:40 +0200
Message-ID: <1343899420.9299.118.camel@edumazet-glaptop>
References: <1343893753.9299.13.camel@edumazet-glaptop>
	 <20120802.014534.1221330015548828529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45821 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab2HBJXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 05:23:45 -0400
Received: by bkwj10 with SMTP id j10so4145520bkw.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 02:23:44 -0700 (PDT)
In-Reply-To: <20120802.014534.1221330015548828529.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-02 at 01:45 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 02 Aug 2012 09:49:13 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Remove some unused includes and sysctls after route cache removal.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> I'm largely against removing the (now pointless) sysctls.
> 
> If the settings do nothing, so be it.
> 
> But it shouldn't generate warnings and errors during bootup,
> which is what removing them is going to do.

Are you referring to a stale key in your /etc/sysctl.conf ?

I see no distro setting any of the route knob in their sysctl.conf file.



[PATCH v2] ipv4: route.c cleanup

Remove unused includes after IP cache removal

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/route.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c035251..67790ba 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -70,7 +70,6 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
 #include <linux/string.h>
 #include <linux/socket.h>
 #include <linux/sockios.h>
@@ -80,7 +79,6 @@
 #include <linux/netdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/init.h>
-#include <linux/workqueue.h>
 #include <linux/skbuff.h>
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
@@ -88,11 +86,9 @@
 #include <linux/mroute.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/random.h>
-#include <linux/jhash.h>
 #include <linux/rcupdate.h>
 #include <linux/times.h>
 #include <linux/slab.h>
-#include <linux/prefetch.h>
 #include <net/dst.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
