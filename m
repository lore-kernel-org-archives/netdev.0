From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] CONFIG_SMP should be CONFIG_RPS
Date: Tue, 13 Apr 2010 22:36:46 +0800
Message-ID: <1271169406-8115-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:56434 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420Ab0DMGga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 02:36:30 -0400
Received: by gwaa18 with SMTP id a18so420779gwa.19
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 23:36:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_SMP should be CONFIG_RPS

CONFIG_SMP should be CONFIG_RPS

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d1a21b5..0efb36e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1331,7 +1331,7 @@ struct softnet_data {
 	struct sk_buff		*completion_queue;
 
 	/* Elements below can be accessed between CPUs for RPS */
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
 #endif
 	struct sk_buff_head	input_pkt_queue;
