From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 7/7] enic: Mark intr_timer in vnic_enet_config as
	deprecated
Date: Tue, 10 Aug 2010 21:55:26 -0700
Message-ID: <20100811045526.3877.69697.stgit@savbu-pc100.cisco.com>
References: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:13281 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932472Ab0HKEz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:55:26 -0400
In-Reply-To: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>



Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
---
 drivers/net/enic/vnic_enet.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/enic/vnic_enet.h b/drivers/net/enic/vnic_enet.h
index 3b32912..e8740e3 100644
--- a/drivers/net/enic/vnic_enet.h
+++ b/drivers/net/enic/vnic_enet.h
@@ -30,7 +30,7 @@ struct vnic_enet_config {
 	u32 wq_desc_count;
 	u32 rq_desc_count;
 	u16 mtu;
-	u16 intr_timer;
+	u16 intr_timer_deprecated;
 	u8 intr_timer_type;
 	u8 intr_mode;
 	char devname[16];

