From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 3/25] iwlegacy: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:26:50 +0200
Message-ID: <1405697232-11785-4-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Not tested.

 drivers/net/wireless/iwlegacy/3945.c     |    2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index b598e28..93bdf68 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -2728,7 +2728,7 @@ static struct il_cfg il3945_abg_cfg = {
 	},
 };
 
-DEFINE_PCI_DEVICE_TABLE(il3945_hw_card_ids) = {
+const struct pci_device_id il3945_hw_card_ids[] = {
 	{IL_PCI_DEVICE(0x4222, 0x1005, il3945_bg_cfg)},
 	{IL_PCI_DEVICE(0x4222, 0x1034, il3945_bg_cfg)},
 	{IL_PCI_DEVICE(0x4222, 0x1044, il3945_bg_cfg)},
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index c159c05..3dcbe2c 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -6800,7 +6800,7 @@ il4965_txq_set_sched(struct il_priv *il, u32 mask)
  *****************************************************************************/
 
 /* Hardware specific file defines the PCI IDs table for that hardware module */
-static DEFINE_PCI_DEVICE_TABLE(il4965_hw_card_ids) = {
+static const struct pci_device_id il4965_hw_card_ids[] = {
 	{IL_PCI_DEVICE(0x4229, PCI_ANY_ID, il4965_cfg)},
 	{IL_PCI_DEVICE(0x4230, PCI_ANY_ID, il4965_cfg)},
 	{0}
