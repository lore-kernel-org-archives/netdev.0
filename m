From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Update truesize with the length of the packet for packet split
Date: Tue, 25 Apr 2006 23:16:29 -0700
Message-ID: <20060426061628.25966.93051.stgit@gitlost.site>
References: <20060426061229.25966.83974.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Miller, David" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:11525 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1750784AbWDZGM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 02:12:27 -0400
To: stable@kernel.org, "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060426061229.25966.83974.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Update skb with the real packet size.


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/e1000/e1000_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index add8dc4..c99e878 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3768,6 +3768,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 			ps_page->ps_page[j] = NULL;
 			skb->len += length;
 			skb->data_len += length;
+			skb->truesize += length;
 		}
 
 copydone:



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro(R) Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
