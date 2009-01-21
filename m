From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 7/9] bnx2x: annotate more fields in  struct eth_tx_bd_flags
Date: Tue, 20 Jan 2009 21:50:50 -0800
Message-ID: <1232517051.9701.25.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:24781 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbZAUFu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:50:59 -0500
Received: by wf-out-1314.google.com with SMTP id 27so4192261wfd.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 21:50:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/bnx2x_hsi.h  |    6 +++---
 drivers/net/bnx2x_main.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index ba066b7..33d6d5d 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1910,9 +1910,9 @@ struct eth_tx_bd_flags {
 struct eth_tx_bd {
 	__le32 addr_lo;
 	__le32 addr_hi;
-	u16 nbd;
-	u16 nbytes;
-	u16 vlan;
+	__le16 nbd;
+	__le16 nbytes;
+	__le16 vlan;
 	struct eth_tx_bd_flags bd_flags;
 	u8 general_data;
 #define ETH_TX_BD_HDR_NBDS (0x3F<<0)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f37c8ff..3d0907b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9383,7 +9383,7 @@ static noinline u16 bnx2x_tx_split(struct bnx2x *bp,
 	d_tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	d_tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
 	d_tx_bd->nbytes = cpu_to_le16(old_len - hlen);
-	d_tx_bd->vlan = 0;
+	d_tx_bd->vlan = cpu_to_le16(0);
 	/* this marks the BD as one that has no individual mapping
 	 * the FW ignores this flag in a BD not marked start
 	 */
-- 
1.6.1.249.g455e5


