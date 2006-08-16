From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 03/13] e1000: Same cosmetic fix as earlier sent out for IPV4.
Date: Wed, 16 Aug 2006 14:56:22 -0700
Message-ID: <20060816215621.27080.97928.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:55049 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932253AbWHPVsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:33 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 627f224..ea3d504 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2545,7 +2545,7 @@ e1000_tso(struct e1000_adapter *adapter,
 			cmd_length = E1000_TXD_CMD_IP;
 			ipcse = skb->h.raw - skb->data - 1;
 #ifdef NETIF_F_TSO_IPV6
-		} else if (skb->protocol == ntohs(ETH_P_IPV6)) {
+		} else if (skb->protocol == htons(ETH_P_IPV6)) {
 			skb->nh.ipv6h->payload_len = 0;
 			skb->h.th->check =
 				~csum_ipv6_magic(&skb->nh.ipv6h->saddr,



--
Auke Kok <auke-jan.h.kok@intel.com>
