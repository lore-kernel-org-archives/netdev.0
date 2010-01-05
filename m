From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/vxge/vxge-main.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 09:59:23 -0700
Message-ID: <201001050959.23591.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755164Ab0AEREq@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

Repost due to merge issues.

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 0fdfd58..df13873 100644
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
