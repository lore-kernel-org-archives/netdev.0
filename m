From: Syam Sidhardhan <syamsidhardh@gmail.com>
Subject: [PATCH] net/pasemi: Fix missing coding style
Date: Mon, 25 Feb 2013 04:31:19 +0530
Message-ID: <1361746879-29261-1-git-send-email-s.syam@samsung.com>
Cc: syamsidhardh@gmail.com, olof@lixom.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:51152 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763Ab3BXXBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 18:01:33 -0500
Received: by mail-da0-f49.google.com with SMTP id t11so238488daj.8
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2013 15:01:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix missing () & { }

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 drivers/net/ethernet/pasemi/pasemi_mac.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 0be5844..b1cfbb7 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -579,8 +579,9 @@ static void pasemi_mac_free_tx_resources(struct pasemi_mac *mac)
 						(TX_RING_SIZE-1)].dma;
 			freed = pasemi_mac_unmap_tx_skb(mac, nfrags,
 							info->skb, dmas);
-		} else
+		} else {
 			freed = 2;
+		}
 	}
 
 	kfree(txring->ring_info);
@@ -808,8 +809,9 @@ static int pasemi_mac_clean_rx(struct pasemi_mac_rxring *rx,
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			skb->csum = (macrx & XCT_MACRX_CSUM_M) >>
 					   XCT_MACRX_CSUM_S;
-		} else
+		} else {
 			skb_checksum_none_assert(skb);
+		}
 
 		packets++;
 		tot_bytes += len;
@@ -1829,10 +1831,11 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&mac->pdev->dev, "register_netdev failed with error %d\n",
 			err);
 		goto out;
-	} else if netif_msg_probe(mac)
+	} else if (netif_msg_probe(mac)) {
 		printk(KERN_INFO "%s: PA Semi %s: intf %d, hw addr %pM\n",
 		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
 		       mac->dma_if, dev->dev_addr);
+	}
 
 	return err;
 
-- 
1.7.9.5
