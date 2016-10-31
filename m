From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ath9k_htc: fix minor mistakes in dev_err messages
Date: Mon, 31 Oct 2016 09:12:47 -0600
Message-ID: <20161031151247.18127-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Add missing space in a dev_err message and join wrapped text so
it does not span multiple lines.  Fix spelling mistake on "unknown".

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ath/ath9k/htc_hst.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index fd85f99..8e6dae2 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -244,8 +244,8 @@ int htc_connect_service(struct htc_target *target,
 	/* Find an available endpoint */
 	endpoint = get_next_avail_ep(target->endpoint);
 	if (!endpoint) {
-		dev_err(target->dev, "Endpoint is not available for"
-			"service %d\n", service_connreq->service_id);
+		dev_err(target->dev, "Endpoint is not available for service %d\n",
+			service_connreq->service_id);
 		return -EINVAL;
 	}
 
@@ -382,7 +382,7 @@ static void ath9k_htc_fw_panic_report(struct htc_target *htc_handle,
 		break;
 		}
 	default:
-		dev_err(htc_handle->dev, "ath: uknown panic pattern!\n");
+		dev_err(htc_handle->dev, "ath: unknown panic pattern!\n");
 		break;
 	}
 }
-- 
2.9.3
