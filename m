From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 13/20] zd1211rw: fix misspelling of current function in string
Date: Sun,  7 Dec 2014 20:20:55 +0100
Message-ID: <1417980062-25151-14-git-send-email-Julia.Lawall@lip6.fr>
References: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux@rasmusvillemoes.dk,
	joe@perches.com, Ulrich Kunitz <kune@deine-taler.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace a misspelled function name by %s and then __func__.

This was done using Coccinelle, including the use of Levenshtein distance,
as proposed by Rasmus Villemoes.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch is difficult to summarize, but is available in the cover
letter of this patch series.

 drivers/net/wireless/zd1211rw/zd_chip.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 73a49b8..07b94ed 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -129,7 +129,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *values, const zd_addr_t *addr
 	r = zd_ioread16v_locked(chip, v16, a16, count16);
 	if (r) {
 		dev_dbg_f(zd_chip_dev(chip),
-			  "error: zd_ioread16v_locked. Error number %d\n", r);
+			  "error: %s. Error number %d\n", __func__, r);
 		return r;
 	}
 
@@ -256,8 +256,8 @@ int zd_iowrite32a_locked(struct zd_chip *chip,
 		if (r) {
 			zd_usb_iowrite16v_async_end(&chip->usb, 0);
 			dev_dbg_f(zd_chip_dev(chip),
-				"error _zd_iowrite32v_locked."
-				" Error number %d\n", r);
+				"error _%s. Error number %d\n", __func__,
+				r);
 			return r;
 		}
 	}
