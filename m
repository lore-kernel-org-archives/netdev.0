From: Punit Vara <punitvara@gmail.com>
Subject: [RESEND PATCH 02/10] net: wireless: ath: Remove unnecessary semicolon
Date: Wed, 28 Oct 2015 00:32:37 +0530
Message-ID: <1445972565-14963-2-git-send-email-punitvara@gmail.com>
References: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the ath10k/wmi.h that removes unneeded semicolon which
 is reported by coccicheck.

Here semicolon just create empty statement so please remote it.

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/ath/ath10k/wmi.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/wmi.h b/drivers/net/wireless/ath/ath10k/wmi.h
index 52d3503..21d5b6b 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.h
+++ b/drivers/net/wireless/ath/ath10k/wmi.h
@@ -1675,7 +1675,7 @@ static inline const char *ath10k_wmi_phymode_str(enum wmi_phy_mode mode)
 
 		/* no default handler to allow compiler to check that the
 		 * enum is fully handled */
-	};
+	}
 
 	return "<unknown>";
 }
-- 
2.5.3
