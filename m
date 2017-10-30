From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] atm: iphase: Fix space before '[' error.
Date: Mon, 30 Oct 2017 21:22:03 +0530
Message-ID: <dd0d00d92d7d5b6c5d7d8f5d2d0c7e4b0a4b8cc2.1509378592.git.arvind.yadav.cs@gmail.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: 3chas3@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix checkpatch.pl error:
ERROR: space prohibited before open square bracket '['.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/iphase.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index fc72b763..a785c6e 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -880,7 +880,7 @@ static void ia_phy_write(struct iadev_priv *iadev,
 
 static void ia_suni_pm7345_init_ds3(struct iadev_priv *iadev)
 {
-	static const struct ia_reg suni_ds3_init [] = {
+	static const struct ia_reg suni_ds3_init[] = {
 		{ SUNI_DS3_FRM_INTR_ENBL,	0x17 },
 		{ SUNI_DS3_FRM_CFG,		0x01 },
 		{ SUNI_DS3_TRAN_CFG,		0x01 },
@@ -898,7 +898,7 @@ static void ia_suni_pm7345_init_ds3(struct iadev_priv *iadev)
 
 static void ia_suni_pm7345_init_e3(struct iadev_priv *iadev)
 {
-	static const struct ia_reg suni_e3_init [] = {
+	static const struct ia_reg suni_e3_init[] = {
 		{ SUNI_E3_FRM_FRAM_OPTIONS,		0x04 },
 		{ SUNI_E3_FRM_MAINT_OPTIONS,		0x20 },
 		{ SUNI_E3_FRM_FRAM_INTR_ENBL,		0x1d },
@@ -918,7 +918,7 @@ static void ia_suni_pm7345_init_e3(struct iadev_priv *iadev)
 
 static void ia_suni_pm7345_init(struct iadev_priv *iadev)
 {
-	static const struct ia_reg suni_init [] = {
+	static const struct ia_reg suni_init[] = {
 		/* Enable RSOP loss of signal interrupt. */
 		{ SUNI_INTR_ENBL,		0x28 },
 		/* Clear error counters. */
-- 
2.7.4
