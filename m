From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/3] gianfar: constify giant block of status descriptor strings
Date: Sun, 18 Mar 2012 12:56:26 -0400
Message-ID: <1332089787-24086-3-git-send-email-paul.gortmaker@windriver.com>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net, eric.dumazet@gmail.com, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43542 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906Ab2CRQ4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 12:56:52 -0400
In-Reply-To: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 5a78d55..8d74efd 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -58,7 +58,7 @@ static void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rv
 static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rvals);
 static void gfar_gdrvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo);
 
-static char stat_gstrings[][ETH_GSTRING_LEN] = {
+static const char stat_gstrings[][ETH_GSTRING_LEN] = {
 	"rx-dropped-by-kernel",
 	"rx-large-frame-errors",
 	"rx-short-frame-errors",
-- 
1.7.9.1
