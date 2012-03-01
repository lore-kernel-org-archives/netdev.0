From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 2/7] cris/eth_v10: use dev_set_mac_address() instead of e100_set_mac_address()
Date: Thu,  1 Mar 2012 17:52:22 +0100
Message-ID: <1330620747-4047-3-git-send-email-danny.kukawka@bisect.de>
References: <1330620747-4047-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Javier Martinez Canillas <martinez.javier@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330620747-4047-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_set_mac_address() instead of e100_set_mac_address() directly
to get validation checks for free.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
---
 drivers/net/cris/eth_v10.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 7cb2785..ce6f3e6 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -377,8 +377,7 @@ etrax_ethernet_init(void)
 	}
 
 	/* set the default MAC address */
-
-	e100_set_mac_address(dev, &default_mac);
+	dev_set_mac_address(dev, &default_mac);
 
 	/* Initialize speed indicator stuff. */
 
-- 
1.7.8.3
