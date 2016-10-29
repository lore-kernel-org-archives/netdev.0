From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: [PATCH 1/1] ath10k: use the right length of "background"
Date: Sat, 29 Oct 2016 13:17:37 +0200
Message-ID: <20161029111737.19034-1-nicolas.iooss_linux@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, Nicolas Iooss <nicolas.iooss_linux@m4x.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>,
	ath10k@lists.infradead.org
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The word "background" contains 10 characters so the third argument of
strncmp() need to be 10 in order to match this prefix correctly.

Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Fixes: 855aed1220d2 ("ath10k: add spectral scan feature")
---
 drivers/net/wireless/ath/ath10k/spectral.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/spectral.c b/drivers/net/wireless/ath/ath10k/spectral.c
index 7d9b0da1b010..2ffc1fe4923b 100644
--- a/drivers/net/wireless/ath/ath10k/spectral.c
+++ b/drivers/net/wireless/ath/ath10k/spectral.c
@@ -338,7 +338,7 @@ static ssize_t write_file_spec_scan_ctl(struct file *file,
 		} else {
 			res = -EINVAL;
 		}
-	} else if (strncmp("background", buf, 9) == 0) {
+	} else if (strncmp("background", buf, 10) == 0) {
 		res = ath10k_spectral_scan_config(ar, SPECTRAL_BACKGROUND);
 	} else if (strncmp("manual", buf, 6) == 0) {
 		res = ath10k_spectral_scan_config(ar, SPECTRAL_MANUAL);
-- 
2.10.1
