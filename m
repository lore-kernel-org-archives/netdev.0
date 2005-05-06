From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/ieee80211/: make two functions static
Date: Fri, 6 May 2005 23:32:39 +0200
Message-ID: <20050506213238.GS3590@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch makes two needlessly global functions static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/ieee80211/ieee80211_crypt_ccmp.c |    4 ++--
 net/ieee80211/ieee80211_tx.c         |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

--- linux-2.6.12-rc3-mm2-full/net/ieee80211/ieee80211_crypt_ccmp.c.old	2005-05-05 02:29:22.000000000 +0200
+++ linux-2.6.12-rc3-mm2-full/net/ieee80211/ieee80211_crypt_ccmp.c	2005-05-05 02:29:35.000000000 +0200
@@ -59,8 +59,8 @@
 	u8 rx_b0[AES_BLOCK_LEN], rx_b[AES_BLOCK_LEN], rx_a[AES_BLOCK_LEN];
 };
 
-void ieee80211_ccmp_aes_encrypt(struct crypto_tfm *tfm,
-			     const u8 pt[16], u8 ct[16])
+static void ieee80211_ccmp_aes_encrypt(struct crypto_tfm *tfm,
+				       const u8 pt[16], u8 ct[16])
 {
 	struct scatterlist src, dst;
 
--- linux-2.6.12-rc3-mm2-full/net/ieee80211/ieee80211_tx.c.old	2005-05-05 02:29:51.000000000 +0200
+++ linux-2.6.12-rc3-mm2-full/net/ieee80211/ieee80211_tx.c	2005-05-05 02:29:59.000000000 +0200
@@ -211,8 +211,8 @@
 	kfree(txb);
 }
 
-struct ieee80211_txb *ieee80211_alloc_txb(int nr_frags, int txb_size,
-					  int gfp_mask)
+static struct ieee80211_txb *ieee80211_alloc_txb(int nr_frags, int txb_size,
+						 int gfp_mask)
 {
 	struct ieee80211_txb *txb;
 	int i;
