From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] iwlegacy: Add missing comma between constant string array
Date: Fri,  8 Jul 2011 23:20:24 -0700
Message-ID: <36f8b5d1a32b8702941ebeda7a406188af132e9e.1310187270.git.joe@perches.com>
References: <cover.1310187270.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1310187270.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Multiple quoted strings are concatenated without comma separators.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/iwlegacy/iwl4965-base.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/iwl4965-base.c b/drivers/net/wireless/iwlegacy/iwl4965-base.c
index 46242d2..1433466 100644
--- a/drivers/net/wireless/iwlegacy/iwl4965-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl4965-base.c
@@ -1484,7 +1484,7 @@ static const char * const desc_lookup_text[] = {
 	"NMI_INTERRUPT_DATA_ACTION_PT",
 	"NMI_TRM_HW_ER",
 	"NMI_INTERRUPT_TRM",
-	"NMI_INTERRUPT_BREAK_POINT"
+	"NMI_INTERRUPT_BREAK_POINT",
 	"DEBUG_0",
 	"DEBUG_1",
 	"DEBUG_2",
-- 
1.7.6.131.g99019
