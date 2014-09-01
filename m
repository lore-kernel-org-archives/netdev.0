From: David Wood <devel@dtwood.uk>
Subject: [PATCH] ethernet: nvidia: Remove extra parens
Date: Mon, 1 Sep 2014 15:31:55 -0700
Message-ID: <20140901223152.GA3066@dtw-laptop.attlocal.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexander Gordeev <agordeev@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Antonio Ospite <ao2@ao2.it>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	Ivan Vecera <ivecera@redhat.com>, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary double parenthesis around if statement.

Signed-off-by: David Wood <devel@dtwood.uk>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 925b296..f39cae6 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1481,7 +1481,7 @@ static int phy_init(struct net_device *dev)
 	}
 
 	/* phy vendor specific configuration */
-	if ((np->phy_oui == PHY_OUI_CICADA)) {
+	if (np->phy_oui == PHY_OUI_CICADA) {
 		if (init_cicada(dev, np, phyinterface)) {
 			netdev_info(dev, "%s: phy init failed\n",
 				    pci_name(np->pci_dev));
-- 
2.0.3
