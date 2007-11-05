From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 2/5] phylib: add PHY interface modes for internal delay for
 tx and rx only
Date: Mon, 5 Nov 2007 12:15:39 -0600
Message-ID: <20071105121539.9a1d6cbb.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, paulus@samba.org
To: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:33260 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbXKESQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 13:16:06 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow phylib specification of cases where hardware needs to configure
PHYs for Internal Delay only on either RX or TX (not both).

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 include/linux/phy.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index f0742b6..e10763d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -58,6 +58,8 @@ typedef enum {
 	PHY_INTERFACE_MODE_RMII,
 	PHY_INTERFACE_MODE_RGMII,
 	PHY_INTERFACE_MODE_RGMII_ID,
+	PHY_INTERFACE_MODE_RGMII_RXID,
+	PHY_INTERFACE_MODE_RGMII_TXID,
 	PHY_INTERFACE_MODE_RTBI
 } phy_interface_t;
 
-- 
1.5.2.2

