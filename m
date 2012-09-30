From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH V2] ath/ath9k/ar9003_eeprom.c: Remove
	semicolon after if
Date: Sun, 30 Sep 2012 22:56:39 +0200
Message-ID: <1349038599-22026-1-git-send-email-peter.senna@gmail.com>
References: <1349032870-4780-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vthiagar@qca.qualcomm.com, kernel-janitors@vger.kernel.org,
	jouni@qca.qualcomm.com, Peter Senna Tschudin <peter.senna@gmail.com>,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com,
	linux-kernel@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, senthilb@qca.qualcomm.com
To: mcgrof@qca.qualcomm.com
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <1349032870-4780-1-git-send-email-peter.senna@gmail.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

The semantic patch that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r1@
position p;
@@
if (...);@p

@script:python@
p0 << r1.p;
@@
// Emacs org-mode output
cocci.print_main("", p0)
cocci.print_secs("", p0)
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
NOTE: This patch changes the semantics.

Changes from V1:
Commit message
Added a note about semantics change

 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 5bbe505..189aeb2 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -2989,7 +2989,7 @@ static u32 ath9k_hw_ar9300_get_eeprom(struct ath_hw *ah,
 	case EEP_PAPRD:
 		if (AR_SREV_9462(ah))
 			return false;
-		if (!ah->config.enable_paprd);
+		if (!ah->config.enable_paprd)
 			return false;
 		return !!(pBase->featureEnable & BIT(5));
 	case EEP_CHAIN_MASK_REDUCE:
-- 
1.7.11.4
