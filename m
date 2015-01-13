From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] atm: lanai: Remove unused function
Date: Tue, 13 Jan 2015 19:45:19 +0100
Message-ID: <1421174719-5371-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the function aal5_spacefor() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/atm/lanai.c |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 93eaf8d..d2e9ea8 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -681,15 +681,6 @@ static inline int aal5_size(int size)
 	return cells * 48;
 }
 
-/* How many bytes can we send if we have "space" space, assuming we have
- * to send full cells
- */
-static inline int aal5_spacefor(int space)
-{
-	int cells = space / 48;
-	return cells * 48;
-}
-
 /* -------------------- FREE AN ATM SKB: */
 
 static inline void lanai_free_skb(struct atm_vcc *atmvcc, struct sk_buff *skb)
-- 
1.7.10.4
