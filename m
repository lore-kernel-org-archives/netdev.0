From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] iwlwifi: remove duplicate includes
Date: Sun, 20 Oct 2013 07:01:00 +0200
Message-ID: <1382245260-19065-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
	ilw@linux.intel.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:33467 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750824Ab3JTFBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 01:01:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by "make includecheck"

Tested that the corresponding sources still compile well on x86

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/wireless/iwlwifi/iwl-io.c  | 1 -
 drivers/net/wireless/iwlwifi/mvm/mvm.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-io.c b/drivers/net/wireless/iwlwifi/iwl-io.c
index dfa4d2e..ad8e19a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-io.c
+++ b/drivers/net/wireless/iwlwifi/iwl-io.c
@@ -34,7 +34,6 @@
 #include "iwl-csr.h"
 #include "iwl-debug.h"
 #include "iwl-fh.h"
-#include "iwl-csr.h"
 
 #define IWL_POLL_INTERVAL 10	/* microseconds */
 
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/iwlwifi/mvm/mvm.h
index b038927..bd80865 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/iwlwifi/mvm/mvm.h
@@ -73,7 +73,6 @@
 #include "iwl-trans.h"
 #include "iwl-notif-wait.h"
 #include "iwl-eeprom-parse.h"
-#include "iwl-trans.h"
 #include "sta.h"
 #include "fw-api.h"
 #include "constants.h"
-- 
1.8.1.2
