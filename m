From: Alessandro Rubini <rubini@gnudd.com>
Subject: [PATCH 1/3] stmmac: added PCI identifiers
Date: Tue, 24 Jan 2012 10:08:56 +0100
Message-ID: <e05c69415f05b3dbca26cd8255374de3656dcbff.1327394751.git.rubini@gnudd.com>
References: <cover.1327394750.git.rubini@gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: giancarlo.asnaghi@st.com
To: linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1327394750.git.rubini@gnudd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


STM has a device ID within its own VENDOR space, and it is being
used in the STA2X11 I/O Hub.

Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 54a819a..c796de9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -170,9 +170,9 @@ static int stmmac_pci_resume(struct pci_dev *pdev)
 #define STMMAC_DEVICE_ID 0x1108
 
 static DEFINE_PCI_DEVICE_TABLE(stmmac_id_table) = {
-	{
-	PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)}, {
-	}
+	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)},
+	{PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC)},
+	{}
 };
 
 MODULE_DEVICE_TABLE(pci, stmmac_id_table);
-- 
1.7.7.2
