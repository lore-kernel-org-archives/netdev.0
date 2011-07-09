From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] benet: Add missing comma between constant string array
Date: Fri,  8 Jul 2011 23:20:23 -0700
Message-ID: <8c2d9b2ff796489a39408fade30fc93ed6040b3c.1310187270.git.joe@perches.com>
References: <cover.1310187270.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1310187270.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Multiple quoted strings are concatenated without comma separators.

Make the arrays const while there.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/benet/be_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 696f634..4ebd700 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -44,7 +44,7 @@ static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
 /* UE Status Low CSR */
-static char *ue_status_low_desc[] = {
+static const char * const ue_status_low_desc[] = {
 	"CEV",
 	"CTX",
 	"DBUF",
@@ -79,7 +79,7 @@ static char *ue_status_low_desc[] = {
 	"MPU_INTPEND"
 };
 /* UE Status High CSR */
-static char *ue_status_hi_desc[] = {
+static const char * const ue_status_hi_desc[] = {
 	"LPCMEMHOST",
 	"MGMT_MAC",
 	"PCS0ONLINE",
@@ -103,7 +103,7 @@ static char *ue_status_hi_desc[] = {
 	"HOST7",
 	"HOST8",
 	"HOST9",
-	"NETC"
+	"NETC",
 	"Unknown",
 	"Unknown",
 	"Unknown",
-- 
1.7.6.131.g99019
