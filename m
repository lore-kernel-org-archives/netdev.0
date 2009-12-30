From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/vxge/vxge-main.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 13:34:18 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F640@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753210AbZL3SeU@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index f1c4b2a..5f0e7ea 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -4297,10 +4297,8 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 	vxge_debug_init(VXGE_TRACE, "%s: Neterion %s Server Adapter",
 		vdev->ndev->name, ll_config.device_hw_info.product_desc);
 
-	vxge_debug_init(VXGE_TRACE,
-		"%s: MAC ADDR: %02X:%02X:%02X:%02X:%02X:%02X",
-		vdev->ndev->name, macaddr[0], macaddr[1], macaddr[2],
-		macaddr[3], macaddr[4], macaddr[5]);
+	vxge_debug_init(VXGE_TRACE, "%s: MAC ADDR: %pM",
+		vdev->ndev->name, macaddr);
 
 	vxge_debug_init(VXGE_TRACE, "%s: Link Width x%d",
 		vdev->ndev->name, vxge_hw_device_link_width_get(hldev)); 
