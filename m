From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 21/26] net: mvneta: enable flow control for PHY
 connections
Date: Mon, 07 Dec 2015 17:38:59 +0000
Message-ID: <E1a5zkZ-00076c-1e@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60315 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932679AbbLGRjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:39:02 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable flow control support for PHY connections by indicating our
support via the ethtool capabilities.  phylink takes care of the
appropriate handling.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/marvell/mvneta.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 00cfb120e324..165dfab134b7 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2600,12 +2600,14 @@ static int mvneta_mac_support(struct net_device *ndev, unsigned int mode,
 		state->supported = PHY_10BT_FEATURES |
 				   PHY_100BT_FEATURES |
 				   SUPPORTED_1000baseT_Full |
+				   SUPPORTED_Pause |
 				   SUPPORTED_Autoneg;
 		state->advertising = ADVERTISED_10baseT_Half |
 				     ADVERTISED_10baseT_Full |
 				     ADVERTISED_100baseT_Half |
 				     ADVERTISED_100baseT_Full |
 				     ADVERTISED_1000baseT_Full |
+				     ADVERTISED_Pause |
 				     ADVERTISED_Autoneg;
 		state->an_enabled = 1;
 		break;
-- 
2.1.0
