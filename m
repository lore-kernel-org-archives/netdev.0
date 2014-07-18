From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 21/25] hostap: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:27:08 +0200
Message-ID: <1405697232-11785-22-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jouni Malinen <j@w1.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/wireless/hostap/hostap_pci.c |    2 +-
 drivers/net/wireless/hostap/hostap_plx.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 91158e2..c864ef4 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -39,7 +39,7 @@ struct hostap_pci_priv {
 /* FIX: do we need mb/wmb/rmb with memory operations? */
 
 
-static DEFINE_PCI_DEVICE_TABLE(prism2_pci_id_table) = {
+static const struct pci_device_id prism2_pci_id_table[] = {
 	/* Intersil Prism3 ISL3872 11Mb/s WLAN Controller */
 	{ 0x1260, 0x3872, PCI_ANY_ID, PCI_ANY_ID },
 	/* Intersil Prism2.5 ISL3874 11Mb/s WLAN Controller */
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index 3bf530d..4901a99 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -60,7 +60,7 @@ struct hostap_plx_priv {
 
 #define PLXDEV(vendor,dev,str) { vendor, dev, PCI_ANY_ID, PCI_ANY_ID }
 
-static DEFINE_PCI_DEVICE_TABLE(prism2_plx_id_table) = {
+static const struct pci_device_id prism2_plx_id_table[] = {
 	PLXDEV(0x10b7, 0x7770, "3Com AirConnect PCI 777A"),
 	PLXDEV(0x111a, 0x1023, "Siemens SpeedStream SS1023"),
 	PLXDEV(0x126c, 0x8030, "Nortel emobility"),
