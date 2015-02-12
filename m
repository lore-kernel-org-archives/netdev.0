From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipvlan: add a missing __percpu pcpu_stats
Date: Wed, 11 Feb 2015 19:51:46 -0800
Message-ID: <1423713106.4942.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:37239 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204AbbBLDvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:51:49 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so624909qcw.6
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 19:51:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Cosmetic patch to add __percpu qualifier to pcpu_stats

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ipvlan/ipvlan.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 2729f64b3e7e..924ea98bd531 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -67,7 +67,7 @@ struct ipvl_dev {
 	struct list_head	addrs;
 	int			ipv4cnt;
 	int			ipv6cnt;
-	struct ipvl_pcpu_stats	*pcpu_stats;
+	struct ipvl_pcpu_stats	__percpu *pcpu_stats;
 	DECLARE_BITMAP(mac_filters, IPVLAN_MAC_FILTER_SIZE);
 	netdev_features_t	sfeatures;
 	u32			msg_enable;
