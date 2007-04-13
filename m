From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH v2 1/7] phylib: add RGMII-ID interface mode definition
Date: Fri, 13 Apr 2007 01:25:57 -0500
Message-ID: <20070413012557.4fe6eceb.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:39433 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbXDMG0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 02:26:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RGMII spec allows compliance for devices that implement an internal
delay on TXC or RXC inside the transmitter.  This patch adds an RGMII_ID
definition to support RGMII-ID devices in the phylib.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
this 7 part series supercedes previous 2-set ucc_geth series submitted 10 apr 2007.
please consider for 2.6.22

 include/linux/phy.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index edd4c88..2a65978 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -55,6 +55,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_TBI,
 	PHY_INTERFACE_MODE_RMII,
 	PHY_INTERFACE_MODE_RGMII,
+	PHY_INTERFACE_MODE_RGMII_ID,
 	PHY_INTERFACE_MODE_RTBI
 } phy_interface_t;
 
-- 
1.5.0.1

