From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH 2/2] liquidio: mark expected switch fall-through in
 octeon_destroy_resources
Date: Tue, 17 Oct 2017 14:01:45 -0500
Message-ID: <20171017190145.GA17015@embeddedor.com>
References: <20171017185920.GA16976@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedorcom>
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171017185920.GA16976@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index e4a112c..4c3b568 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -747,7 +747,7 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 
 		if (lio_wait_for_oq_pkts(oct))
 			dev_err(&oct->pci_dev->dev, "OQ had pending packets\n");
-
+		/* fall through */
 	case OCT_DEV_INTR_SET_DONE:
 		/* Disable interrupts  */
 		oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
-- 
2.7.4
