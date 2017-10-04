From: =?UTF-8?q?Christoph=20B=C3=B6hmwalder?= <christoph@boehmwalder.at>
Subject: [PATCH 2/3] wireless: iwlwifi: function definition cosmetic fix
Date: Wed,  4 Oct 2017 17:56:59 +0200
Message-ID: <20171004155700.18048-3-christoph@boehmwalder.at>
References: <20171004155700.18048-1-christoph@boehmwalder.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Christoph=20B=C3=B6hmwalder?= <christoph@boehmwalder.at>
To: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
        luciano.coelho@intel.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004155700.18048-1-christoph@boehmwalder.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Separate the function from the previous definition with a newline and
put the `static` keyword on the same line, as it just looks nicer.

Signed-off-by: Christoph Böhmwalder <christoph@boehmwalder.at>
---
 drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c b/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
index 0eb815ae97e8..249ee1c7b02f 100644
--- a/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
+++ b/drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c
@@ -325,8 +325,8 @@ static u16 channel_id_to_txp(struct iwl_phy_db *phy_db, u16 ch_id)
 	}
 	return 0xff;
 }
-static
-int iwl_phy_db_get_section_data(struct iwl_phy_db *phy_db,
+
+static int iwl_phy_db_get_section_data(struct iwl_phy_db *phy_db,
 				u32 type, u8 **data, u16 *size, u16 ch_id)
 {
 	struct iwl_phy_db_entry *entry;
-- 
2.13.5
