From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/2] ath: Fix logging message typos
Date: Wed,  1 Dec 2010 21:13:33 -0800
Message-ID: <a345e995a816576a4c2c39aec43716c18011475b.1291266731.git.joe@perches.com>
References: <276469c602c402565b49f99521ea19757429e81e.1291266731.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
To: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>, Jouni Malinen <jmalinen@athero
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
In-Reply-To: <276469c602c402565b49f99521ea19757429e81e.1291266731.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix immunity misspelling.
Standardize strings from multiple modules.
Add spaces between words of concatenated strings.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/ath/ath5k/ani.c          |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c |    4 ++--
 drivers/net/wireless/ath/ath9k/eeprom_4k.c    |    4 ++--
 drivers/net/wireless/ath/ath9k/eeprom_9287.c  |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c   |    2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c      |    6 +++---
 6 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/ani.c b/drivers/net/wireless/ath/ath5k/ani.c
index 6b75b22..9c41881 100644
--- a/drivers/net/wireless/ath/ath5k/ani.c
+++ b/drivers/net/wireless/ath/ath5k/ani.c
@@ -74,7 +74,7 @@ ath5k_ani_set_noise_immunity_level(struct ath5k_hw *ah, int level)
 	static const s8 fr[] = { -78, -80 };
 #endif
 	if (level < 0 || level >= ARRAY_SIZE(sz)) {
-		ATH5K_ERR(ah->ah_sc, "noise immuniy level %d out of range",
+		ATH5K_ERR(ah->ah_sc, "noise immunity level %d out of range",
 			  level);
 		return;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_calib.c b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
index a7705e7..199131e 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
@@ -720,7 +720,7 @@ static bool ar9285_hw_cl_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 		if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL,
 				  AR_PHY_AGC_CONTROL_CAL, 0, AH_WAIT_TIMEOUT)) {
 			ath_dbg(common, ATH_DBG_CALIBRATE,
-				"offset calibration failed to complete in 1ms; noisy ??\n");
+				"offset calibration failed to complete in 1ms; noisy environment?\n");
 			return false;
 		}
 		REG_CLR_BIT(ah, AR_PHY_TURBO, AR_PHY_FC_DYN2040_EN);
@@ -734,7 +734,7 @@ static bool ar9285_hw_cl_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 	if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL,
 			  0, AH_WAIT_TIMEOUT)) {
 		ath_dbg(common, ATH_DBG_CALIBRATE,
-			"offset calibration failed to complete in 1ms; noisy ??\n");
+			"offset calibration failed to complete in 1ms; noisy enfironment?\n");
 		return false;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_4k.c b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
index 35b1a8c..939fc7a 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_4k.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
@@ -90,7 +90,7 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 				}
 			} else {
 				ath_err(common,
-					"Invalid EEPROM Magic. endianness mismatch.\n");
+					"Invalid EEPROM Magic. Endianness mismatch.\n");
 				return -EINVAL;
 			}
 		}
@@ -1178,7 +1178,7 @@ static u16 ath9k_hw_4k_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 	u16 spur_val = AR_NO_SPUR;
 
 	ath_dbg(common, ATH_DBG_ANI,
-		"Getting spur idx %d is2Ghz. %d val %x\n",
+		"Getting spur idx:%d is2Ghz:%d val:%x\n",
 		i, is2GHz, ah->config.spurchans[i][is2GHz]);
 
 	switch (ah->config.spurmode) {
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
index 0be5351..9ec4bc8 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -1150,7 +1150,7 @@ static u16 ath9k_hw_ar9287_get_spur_channel(struct ath_hw *ah,
 	u16 spur_val = AR_NO_SPUR;
 
 	ath_dbg(common, ATH_DBG_ANI,
-		"Getting spur idx %d is2Ghz. %d val %x\n",
+		"Getting spur idx:%d is2Ghz:%d val:%x\n",
 		i, is2GHz, ah->config.spurchans[i][is2GHz]);
 
 	switch (ah->config.spurmode) {
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index 91722fb..9aa31aa 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -1458,7 +1458,7 @@ static u16 ath9k_hw_def_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 	u16 spur_val = AR_NO_SPUR;
 
 	ath_dbg(common, ATH_DBG_ANI,
-		"Getting spur idx %d is2Ghz. %d val %x\n",
+		"Getting spur idx:%d is2Ghz:%d val:%x\n",
 		i, is2GHz, ah->config.spurchans[i][is2GHz]);
 
 	switch (ah->config.spurmode) {
diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index c41ab8c..69b6aca 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -239,7 +239,7 @@ int htc_connect_service(struct htc_target *target,
 	/* Find an available endpoint */
 	endpoint = get_next_avail_ep(target->endpoint);
 	if (!endpoint) {
-		dev_err(target->dev, "Endpoint is not available for"
+		dev_err(target->dev, "Endpoint is not available for "
 			"service %d\n", service_connreq->service_id);
 		return -EINVAL;
 	}
@@ -253,7 +253,7 @@ int htc_connect_service(struct htc_target *target,
 	skb = alloc_skb(sizeof(struct htc_conn_svc_msg) +
 			    sizeof(struct htc_frame_hdr), GFP_ATOMIC);
 	if (!skb) {
-		dev_err(target->dev, "Failed to allocate buf to send"
+		dev_err(target->dev, "Failed to allocate buf to send "
 			"service connect req\n");
 		return -ENOMEM;
 	}
@@ -434,7 +434,7 @@ struct htc_target *ath9k_htc_hw_alloc(void *hif_handle,
 
 	target = kzalloc(sizeof(struct htc_target), GFP_KERNEL);
 	if (!target) {
-		printk(KERN_ERR "Unable to allocate memory for"
+		printk(KERN_ERR "Unable to allocate memory for "
 			"target device\n");
 		return NULL;
 	}
-- 
1.7.3.2.245.g03276.dirty
