From: "W. Trevor King" <wking@tremily.us>
Subject: [PATCH] 8139too: add 1013:1211 PCI ID for a strange SMC1211TX.
Date: Tue, 25 Sep 2012 16:35:54 -0400
Message-ID: <eaafda75f4966acad08dd10e2627d7615b61206c.1348599606.git.wking__5693.99758610434$1348609014$gmane$org@tremily.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Ben Greear <greearb@candelatech.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The FCC ID on the board is HEDEN1207DTXR01, which belongs to Accton
Technology Corporation.  This matches the expected 1113 ID.  Perhaps
my board just has a dying EEPROM?

Signed-off-by: W. Trevor King <wking@tremily.us>
---
I'm not sure if this qualifies as a patch-able issue, but I thought
I'd send it in in case someone else gets bitten by this.

 drivers/net/ethernet/realtek/8139too.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 1d83565..b7cf947 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -238,6 +238,7 @@ static DEFINE_PCI_DEVICE_TABLE(rtl8139_pci_tbl) = {
 	{0x10ec, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x10ec, 0x8138, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
+	{0x1013, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1500, 0x1360, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x4033, 0x1360, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1186, 0x1300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
-- 
1.7.8.6
