From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 04/11] rtlwifi: rtl8723ae: constify pci_device_id.
Date: Mon, 17 Jul 2017 23:39:52 +0530
Message-ID: <1500314995-3181-5-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500314995-3181-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
        kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500314995-3181-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   2775	    912	      0	   3687	    e67	realtek/rtlwifi/rtl8723ae/sw.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   2839	    848	      0	   3687	    e67	realtek/rtlwifi/rtl8723ae/sw.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c
index 7bf9f25..87dc271 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c
@@ -367,7 +367,7 @@ static const struct rtl_hal_cfg rtl8723e_hal_cfg = {
 	.maps[RTL_RC_HT_RATEMCS15] = DESC92C_RATEMCS15,
 };
 
-static struct pci_device_id rtl8723e_pci_ids[] = {
+static const struct pci_device_id rtl8723e_pci_ids[] = {
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8723, rtl8723e_hal_cfg)},
 	{},
 };
-- 
2.7.4
