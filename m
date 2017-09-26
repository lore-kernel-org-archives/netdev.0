From: AceLan Kao <acelan.kao@canonical.com>
Subject: [PATCH 5/6] ath9k: set use_msi=1 on Dell Vostro 15-3572
Date: Tue, 26 Sep 2017 14:41:38 +0800
Message-ID: <1506408099-18488-5-git-send-email-acelan.kao@canonical.com>
References: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BIOS on Dell Vostro 15-3572 blocks legacy interrupts (INTx),
and only allows MSI for WLAN device.

Signed-off-by: AceLan Kao <acelan.kao@canonical.com>
---
 drivers/net/wireless/ath/ath9k/init.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index fce9ac7..e1198e1 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -128,6 +128,14 @@ static const struct dmi_system_id ath9k_quirks[] __initconst = {
 			DMI_MATCH(DMI_PRODUCT_NAME, "Inspiron 3472"),
 		},
 	},
+	{
+		.callback = set_use_msi,
+		.ident = "Dell Vostro 15-3572",
+		.matches = {
+			DMI_MATCH(DMI_SYS_VENDOR, "Dell Inc."),
+			DMI_MATCH(DMI_PRODUCT_NAME, "Vostro 15-3572"),
+		},
+	},
 	{}
 };
 
-- 
2.7.4
