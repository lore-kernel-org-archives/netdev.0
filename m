From: Joe Perches <joe@perches.com>
Subject: [PATCH 6/8] farsync: Update to current logging forms
Date: Sun, 26 Jun 2011 22:01:33 -0700
Message-ID: <a3271494190678572096d0fe3141f98967ea277f.1309150684.git.joe@perches.com>
References: <cover.1309150683.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Kevin Curtis <kevin.curtis@farsite.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3228 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756316Ab1F0FCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 01:02:07 -0400
In-Reply-To: <cover.1309150683.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pr_fmt, pr_<level> and netdev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/farsync.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 0f27f4c..ebb9f24 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -1665,10 +1665,9 @@ check_started_ok(struct fst_card_info *card)
 	 * existing firmware etc so we just report it for the moment.
 	 */
 	if (FST_RDL(card, numberOfPorts) != card->nports) {
-		pr_warning("Port count mismatch on card %d. "
-			   "Firmware thinks %d we say %d\n",
-			   card->card_no,
-			   FST_RDL(card, numberOfPorts), card->nports);
+		pr_warn("Port count mismatch on card %d.  Firmware thinks %d we say %d\n",
+			card->card_no,
+			FST_RDL(card, numberOfPorts), card->nports);
 	}
 }
 
-- 
1.7.6.rc1

