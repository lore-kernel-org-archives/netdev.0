From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 01/11] tlan: Enable activity LED on Olicom OC-2325 and OC-2326
Date: Sat, 21 Jun 2014 16:47:46 +0200
Message-ID: <1403362076-7777-2-git-send-email-linux@rainbow-software.org>
References: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olicom OC-2325 and OC-2326 ethernet cards have an activity LED but it does not
work with tlan driver as it's not enabled. Enable it.
Tested with OC-2326.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 591437e..e7449cb 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -107,8 +107,10 @@ static struct board {
 	{ "Compaq Netelligent 10/100 TX Embedded UTP",
 	  TLAN_ADAPTER_NONE, 0x83 },
 	{ "Olicom OC-2183/2185", TLAN_ADAPTER_USE_INTERN_10, 0x83 },
-	{ "Olicom OC-2325", TLAN_ADAPTER_UNMANAGED_PHY, 0xf8 },
-	{ "Olicom OC-2326", TLAN_ADAPTER_USE_INTERN_10, 0xf8 },
+	{ "Olicom OC-2325", TLAN_ADAPTER_ACTIVITY_LED |
+	  TLAN_ADAPTER_UNMANAGED_PHY, 0xf8 },
+	{ "Olicom OC-2326", TLAN_ADAPTER_ACTIVITY_LED |
+	  TLAN_ADAPTER_USE_INTERN_10, 0xf8 },
 	{ "Compaq Netelligent 10/100 TX UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Netelligent 10 T/2 PCI UTP/coax", TLAN_ADAPTER_NONE, 0x83 },
 	{ "Compaq NetFlex-3/E",
-- 
Ondrej Zary
