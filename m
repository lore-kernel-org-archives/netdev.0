From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH] iwlwifi: iwl-agn.h included twice
Date: Wed, 15 Feb 2012 18:55:16 +0100
Message-ID: <1329328516-4792-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/wireless/iwlwifi/iwl-core.c included 'iwl-agn.h' twice,
remove the duplicate.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/wireless/iwlwifi/iwl-core.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 7bcfa78..5a7720f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -38,7 +38,6 @@
 #include "iwl-core.h"
 #include "iwl-io.h"
 #include "iwl-power.h"
-#include "iwl-agn.h"
 #include "iwl-shared.h"
 #include "iwl-agn.h"
 #include "iwl-trans.h"
-- 
1.7.8.3
