From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] e1000e: add support for 82574 device ID 0x10F6
Date: Tue, 24 Mar 2009 18:32:58 -0700
Message-ID: <20090325013257.12263.34349.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:53371
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbZCYBdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 21:33:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Add device ID for a new variant of the 82574 adapter.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Acked-by: John Ronciak <john.ronciak@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h     |    1 +
 drivers/net/e1000e/netdev.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 11a2f20..d8b8229 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -339,6 +339,7 @@ enum e1e_registers {
 #define E1000_DEV_ID_82573E_IAMT		0x108C
 #define E1000_DEV_ID_82573L			0x109A
 #define E1000_DEV_ID_82574L			0x10D3
+#define E1000_DEV_ID_82574LA			0x10F6
 #define E1000_DEV_ID_82583V                     0x150C
 
 #define E1000_DEV_ID_80003ES2LAN_COPPER_DPT	0x1096
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f388a01..15424ba 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5130,6 +5130,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82573L), board_82573 },
 
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82574L), board_82574 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82574LA), board_82574 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82583V), board_82583 },
 
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_80003ES2LAN_COPPER_DPT),

