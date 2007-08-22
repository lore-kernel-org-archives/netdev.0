From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [07/10] pasemi_mac: Enable LLTX
Date: Wed, 22 Aug 2007 09:13:07 -0500
Message-ID: <20070822141307.GH16830@lixom.net>
References: <20070817205413.548020000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline; filename=pasemi_mac-enable-lltx
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Enable LLTX on pasemi_mac: we're already doing sufficient locking
in the driver to enable it.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: mainline/drivers/net/pasemi_mac.c
===================================================================
--- mainline.orig/drivers/net/pasemi_mac.c
+++ mainline/drivers/net/pasemi_mac.c
@@ -1235,7 +1235,7 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	dev->set_multicast_list = pasemi_mac_set_rx_mode;
 	dev->weight = 64;
 	dev->poll = pasemi_mac_poll;
-	dev->features = NETIF_F_HW_CSUM;
+	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
 
 	err = pasemi_mac_map_regs(mac);
 	if (err)

--
