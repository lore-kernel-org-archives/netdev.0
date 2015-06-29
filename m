From: Nik Nyby <nikolas@gnu.org>
Subject: [PATCH] net: icplus: fix typo in constant name
Date: Mon, 29 Jun 2015 18:40:08 -0400
Message-ID: <1435617608-1735-1-git-send-email-nikolas@gnu.org>
Cc: Nik Nyby <nikolas@gnu.org>
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw,
	netdev@vger.kernel.org, trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eggs.gnu.org ([208.118.235.92]:42723 "EHLO eggs.gnu.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634AbbF2Wsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 18:48:50 -0400
Received: from Debian-exim by eggs.gnu.org with spam-scanned (Exim 4.71)
	(envelope-from <nikolas@gnu.org>)
	id 1Z9hr5-0001lN-1n
	for netdev@vger.kernel.org; Mon, 29 Jun 2015 18:48:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a typo in the IPG_FRAMETOOLONGERRORS constant.

Signed-off-by: Nik Nyby <nikolas@gnu.org>
---
 drivers/net/ethernet/icplus/ipg.c | 2 +-
 drivers/net/ethernet/icplus/ipg.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index ff29036..c3b6af8 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -1028,7 +1028,7 @@ static struct net_device_stats *ipg_nic_get_stats(struct net_device *dev)
 
 	/* detailed rx_errors */
 	sp->stats.rx_length_errors += ipg_r16(IPG_INRANGELENGTHERRORS) +
-		ipg_r16(IPG_FRAMETOOLONGERRRORS);
+		ipg_r16(IPG_FRAMETOOLONGERRORS);
 	sp->stats.rx_crc_errors += ipg_r16(IPG_FRAMECHECKSEQERRORS);
 
 	/* Unutilized IPG statistic registers. */
diff --git a/drivers/net/ethernet/icplus/ipg.h b/drivers/net/ethernet/icplus/ipg.h
index a21e4f5..de60628 100644
--- a/drivers/net/ethernet/icplus/ipg.h
+++ b/drivers/net/ethernet/icplus/ipg.h
@@ -102,7 +102,7 @@ enum ipg_regs {
 #define	IPG_MCSTFRAMESRCVDOK		0xB8
 #define	IPG_BCSTFRAMESRCVDOK		0xBE
 #define	IPG_MACCONTROLFRAMESRCVD	0xC6
-#define	IPG_FRAMETOOLONGERRRORS		0xC8
+#define	IPG_FRAMETOOLONGERRORS		0xC8
 #define	IPG_INRANGELENGTHERRORS		0xCA
 #define	IPG_FRAMECHECKSEQERRORS		0xCC
 #define	IPG_FRAMESLOSTRXERRORS		0xCE
-- 
2.1.4
