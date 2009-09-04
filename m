From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 08/11] enic: bug fix: enable VLAN filtering
Date: Thu, 03 Sep 2009 20:02:29 -0700
Message-ID: <20090904030229.5047.47659.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:6569 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932768AbZIDDC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:02:26 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: bug fix: enable VLAN filtering

Bug fix: enable VLAN filtering

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 6068904..3a55669 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1967,7 +1967,8 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		break;
 	}
 
-	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	netdev->features |= NETIF_F_HW_VLAN_TX |
+		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
 	if (ENIC_SETTING(enic, TXCSUM))
 		netdev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (ENIC_SETTING(enic, TSO))

