From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/7] be2net: Adding more speeds reported by get_settings
Date: Tue, 6 Aug 2013 09:27:15 +0530
Message-ID: <1375761441-22343-2-git-send-email-sathya.perla@emulex.com>
References: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:56548 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083Ab3HFDx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:53:58 -0400
In-Reply-To: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

The new speeds are supported by variants of the Skyhawk-R chip.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    6 ++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    5 ++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 613d887..bef25b7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1464,6 +1464,12 @@ static int be_mac_to_link_speed(int mac_speed)
 		return 1000;
 	case PHY_LINK_SPEED_10GBPS:
 		return 10000;
+	case PHY_LINK_SPEED_20GBPS:
+		return 20000;
+	case PHY_LINK_SPEED_25GBPS:
+		return 25000;
+	case PHY_LINK_SPEED_40GBPS:
+		return 40000;
 	}
 	return 0;
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index eb541f0..9b91608 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -960,7 +960,10 @@ enum {
 	PHY_LINK_SPEED_10MBPS = 0x1,
 	PHY_LINK_SPEED_100MBPS = 0x2,
 	PHY_LINK_SPEED_1GBPS = 0x3,
-	PHY_LINK_SPEED_10GBPS = 0x4
+	PHY_LINK_SPEED_10GBPS = 0x4,
+	PHY_LINK_SPEED_20GBPS = 0x5,
+	PHY_LINK_SPEED_25GBPS = 0x6,
+	PHY_LINK_SPEED_40GBPS = 0x7
 };
 
 struct be_cmd_resp_link_status {
-- 
1.7.1
