From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 7/25] rt2x00: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:26:54 +0200
Message-ID: <1405697232-11785-8-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ivo van Doorn <IvDoorn@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/wireless/rt2x00/rt2400pci.c |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c |    2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c   |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index 4ccfef5..bdf5590 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1821,7 +1821,7 @@ static const struct rt2x00_ops rt2400pci_ops = {
 /*
  * RT2400pci module information.
  */
-static DEFINE_PCI_DEVICE_TABLE(rt2400pci_device_table) = {
+static const struct pci_device_id rt2400pci_device_table[] = {
 	{ PCI_DEVICE(0x1814, 0x0101) },
 	{ 0, }
 };
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index a511ccc..79f4fe6 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -2120,7 +2120,7 @@ static const struct rt2x00_ops rt2500pci_ops = {
 /*
  * RT2500pci module information.
  */
-static DEFINE_PCI_DEVICE_TABLE(rt2500pci_device_table) = {
+static const struct pci_device_id rt2500pci_device_table[] = {
 	{ PCI_DEVICE(0x1814, 0x0201) },
 	{ 0, }
 };
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index a5b32ca..cc1b3cc 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -400,7 +400,7 @@ static const struct rt2x00_ops rt2800pci_ops = {
 /*
  * RT2800pci module information.
  */
-static DEFINE_PCI_DEVICE_TABLE(rt2800pci_device_table) = {
+static const struct pci_device_id rt2800pci_device_table[] = {
 	{ PCI_DEVICE(0x1814, 0x0601) },
 	{ PCI_DEVICE(0x1814, 0x0681) },
 	{ PCI_DEVICE(0x1814, 0x0701) },
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 9048a9c..8194550 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -3075,7 +3075,7 @@ static const struct rt2x00_ops rt61pci_ops = {
 /*
  * RT61pci module information.
  */
-static DEFINE_PCI_DEVICE_TABLE(rt61pci_device_table) = {
+static const struct pci_device_id rt61pci_device_table[] = {
 	/* RT2561s */
 	{ PCI_DEVICE(0x1814, 0x0301) },
 	/* RT2561 v2 */
