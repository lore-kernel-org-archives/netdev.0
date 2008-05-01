From: Becky Bruce <bgill@freescale.com>
Subject: [PATCH] e1000e: use resource_size_t, not unsigned long,
 for phys addrs
Date: Thu, 1 May 2008 18:03:11 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0805011757090.8700@monty.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jgarzik@pobox.com, auke-jan.h.kok@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


The use of unsigned long causes the driver to fail on 32-bit systems
which support 64-bit resources.

Signed-off-by: Becky Bruce <becky.bruce@freescale.com>
---

Resend, with proper CC.

 drivers/net/e1000e/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8991ab8..dae3269 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3897,8 +3897,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	struct e1000_adapter *adapter;
 	struct e1000_hw *hw;
 	const struct e1000_info *ei = e1000_info_tbl[ent->driver_data];
-	unsigned long mmio_start, mmio_len;
-	unsigned long flash_start, flash_len;
+	resource_size_t mmio_start, mmio_len;
+	resource_size_t flash_start, flash_len;
 
 	static int cards_found;
 	int i, err, pci_using_dac;
-- 
1.5.4.1


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
