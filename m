From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/4] netxen: remove unnecessary [kv][mcz]alloc casts
Date: Sun, 28 Nov 2010 01:05:43 -0800
Message-ID: <91d9c137a3d1b90e3c333bb3c6c49537bdb8283e.1290934782.git.joe@perches.com>
References: <cover.1290934782.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290934782.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/netxen/netxen_nic_init.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index f946de2..731077d 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -278,8 +278,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			break;
 
 		}
-		rds_ring->rx_buf_arr = (struct netxen_rx_buffer *)
-			vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
+		rds_ring->rx_buf_arr = vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
 			printk(KERN_ERR "%s: Failed to allocate "
 				"rx buffer ring %d\n",
-- 
1.7.3.2.245.g03276.dirty
