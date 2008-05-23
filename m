From: Li Yang <leoli@freescale.com>
Subject: [PATCH 2/2] ucc_geth_ethtool: Add a missing HW stats counter
Date: Fri, 23 May 2008 18:11:27 +0800
Message-ID: <1211537487-24953-3-git-send-email-leoli@freescale.com>
References: <1211537487-24953-1-git-send-email-leoli@freescale.com>
 <1211537487-24953-2-git-send-email-leoli@freescale.com>
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:55201 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408AbYEWJ7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 05:59:42 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m4N9xdeo029376
	for <netdev@vger.kernel.org>; Fri, 23 May 2008 02:59:40 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m4N9xXcf027564
	for <netdev@vger.kernel.org>; Fri, 23 May 2008 04:59:38 -0500 (CDT)
In-Reply-To: <1211537487-24953-2-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth_ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index b84ffd8..f5839c4 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -73,6 +73,7 @@ static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"tx-frames-ok",
 	"tx-excessive-differ-frames",
 	"tx-256-511-frames",
+	"tx-512-1023-frames",
 	"tx-1024-1518-frames",
 	"tx-jumbo-frames",
 };
-- 
1.5.5.1.248.g4b17

