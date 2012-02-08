From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 03/50] smsc75xx: se dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:10 +0100
Message-ID: <1328735457-29986-4-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/usb/smsc75xx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 3b017bb..aafa6cf 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -615,7 +615,7 @@ static void smsc75xx_init_mac_address(struct usbnet *dev)
 	}
 
 	/* no eeprom, or eeprom values are invalid. generate random MAC */
-	random_ether_addr(dev->net->dev_addr);
+	dev_hw_addr_random(dev->net, dev->net->dev_addr);
 	netif_dbg(dev, ifup, dev->net, "MAC address set to random_ether_addr");
 }
 
-- 
1.7.7.3
