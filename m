From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][27/37] Clean up duplicate includes in net/bridge/
Date: Sat, 21 Jul 2007 17:03:36 +0200
Message-ID: <200707211703.37119.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jesper Juhl <jesper.juhl@gmail.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David S Miller <davem@davemloft.net>,
	Bart De Schuymer <bdschuym@pandora.be>,
	Harald Welte <laforge@netfilter.org>,
	netfilter-devel@lists.netfilter.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Marc Boucher <marc@mbsi.ca>, James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:39272 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939479AbXGUPEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 11:04:36 -0400
Received: by ug-out-1314.google.com with SMTP id j3so799743ugf
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 08:04:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch cleans up duplicate includes in
	net/bridge/


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 031bfa4..89d0d59 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -9,7 +9,6 @@
  *
  */
 
-#include <linux/in.h>
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_log.h>
 #include <linux/netfilter.h>
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 9411db6..a31402a 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -36,7 +36,6 @@
 #include <linux/timer.h>
 #include <linux/netlink.h>
 #include <linux/netdevice.h>
-#include <linux/module.h>
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_ulog.h>
 #include <net/sock.h>
