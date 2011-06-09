From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next 2/2] bonding: delete unused arp_mon_pt
Date: Thu,  9 Jun 2011 10:51:34 +0800
Message-ID: <c89d6db3517fc799050d40b0e2858d2152b5a68e.1307587586.git.panweiping3@gmail.com>
References: <cover.1307587586.git.panweiping3@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Weiping Pan <panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:41179 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894Ab1FICvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 22:51:33 -0400
In-Reply-To: <cover.1307587586.git.panweiping3@gmail.com>
In-Reply-To: <cover.1307587586.git.panweiping3@gmail.com>
References: <cover.1307587586.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now all received packets are handled by bond_handle_frame,
arp_mon_pt isn't used any more.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bonding.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ea1d005..382903f 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -240,7 +240,6 @@ struct bonding {
 	struct   bond_params params;
 	struct   list_head vlan_list;
 	struct   vlan_group *vlgrp;
-	struct   packet_type arp_mon_pt;
 	struct   workqueue_struct *wq;
 	struct   delayed_work mii_work;
 	struct   delayed_work arp_work;
-- 
1.7.4.4

