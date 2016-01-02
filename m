From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v2 1/3] rsi: Delete unnecessary variable initialisations in
 rsi_send_mgmt_pkt()
Date: Sat, 2 Jan 2016 19:27:33 +0100
Message-ID: <56881695.4030308@users.sourceforge.net>
References: <201601030008.47CwzW9c%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201601030008.47CwzW9c%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 2 Jan 2016 19:22:36 +0100

Omit explicit initialisation at the beginning for four local variables
which are redefined before their first use.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/rsi/rsi_91x_pkt.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_pkt.c b/drivers/net/wireless/rsi/rsi_91x_pkt.c
index 702593f..571eaba 100644
--- a/drivers/net/wireless/rsi/rsi_91x_pkt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_pkt.c
@@ -123,15 +123,15 @@ int rsi_send_mgmt_pkt(struct rsi_common *common,
 		      struct sk_buff *skb)
 {
 	struct rsi_hw *adapter = common->priv;
-	struct ieee80211_hdr *wh = NULL;
+	struct ieee80211_hdr *wh;
 	struct ieee80211_tx_info *info;
-	struct ieee80211_bss_conf *bss = NULL;
+	struct ieee80211_bss_conf *bss;
 	struct ieee80211_hw *hw = adapter->hw;
 	struct ieee80211_conf *conf = &hw->conf;
 	struct skb_info *tx_params;
 	int status = -E2BIG;
-	__le16 *msg = NULL;
-	u8 extnd_size = 0;
+	__le16 *msg;
+	u8 extnd_size;
 	u8 vap_id = 0;
 
 	info = IEEE80211_SKB_CB(skb);
-- 
2.6.3
