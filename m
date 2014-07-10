From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 16/33] net: gdm_lte - set name assign type
Date: Thu, 10 Jul 2014 10:17:21 +0200
Message-ID: <1404980258-30853-17-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Won Kang <wkang77@gmail.com>,
	Rashika Kheria <rashika.kheria@gmail.com>,
	devel@driverdev.osuosl.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Devices are named according to the scheme lteXpdnY, where Y is the
nic type, and X is the normal enumeration, so the scheme is NET_NAME_ENUM.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Won Kang <wkang77@gmail.com>
Cc: Rashika Kheria <rashika.kheria@gmail.com>
Cc: devel@driverdev.osuosl.org
---
 drivers/staging/gdm724x/gdm_lte.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/gdm724x/gdm_lte.c b/drivers/staging/gdm724x/gdm_lte.c
index c226852..094a91a 100644
--- a/drivers/staging/gdm724x/gdm_lte.c
+++ b/drivers/staging/gdm724x/gdm_lte.c
@@ -885,7 +885,7 @@ int register_lte_device(struct phy_dev *phy_dev,
 
 		/* Allocate netdev */
 		net = alloc_netdev(sizeof(struct nic), pdn_dev_name,
-				   NET_NAME_UNKNOWN, ether_setup);
+				   NET_NAME_ENUM, ether_setup);
 		if (net == NULL) {
 			pr_err("alloc_netdev failed\n");
 			ret = -ENOMEM;
-- 
1.9.3
