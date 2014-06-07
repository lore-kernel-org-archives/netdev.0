From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: toshiba: ps3_gelic_net.c:  Cleaning up a check on a memory allocation
Date: Sat,  7 Jun 2014 12:22:08 +0200
Message-ID: <1402136528-16857-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	cbe-oss-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Geoff Levand <geoff@infradead.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35236 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaFGKVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 06:21:14 -0400
Received: by mail-wi0-f169.google.com with SMTP id ho1so1986318wib.4
        for <netdev@vger.kernel.org>; Sat, 07 Jun 2014 03:21:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A check on a memory allocation is checked incorrectly.

This was partly found using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/toshiba/ps3_gelic_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index d899d00..bb79928 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1561,7 +1561,7 @@ static struct gelic_card *gelic_alloc_card_net(struct net_device **netdev)
 	 * alloc netdev
 	 */
 	*netdev = alloc_etherdev(sizeof(struct gelic_port));
-	if (!netdev) {
+	if (!*netdev) {
 		kfree(card->unalign);
 		return NULL;
 	}
-- 
1.7.10.4
