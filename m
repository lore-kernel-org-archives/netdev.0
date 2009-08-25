From: Joe Perches <joe@perches.com>
Subject: [PATCH 9/9] s2io.c: Convert skipped nic->config.tx_cfg[i]. to tx_cfg->
Date: Mon, 24 Aug 2009 20:29:48 -0700
Message-ID: <d06ef002f66deffeffdffbd7179afae9688d9309.1251170438.git.joe@perches.com>
References: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Missed doing the conversion in earlier patch.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 06223df..1d13f60 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1001,7 +1001,7 @@ static void free_shared_mem(struct s2io_nic *nic)
 			swstats->mem_freed += PAGE_SIZE;
 		}
 		kfree(fifo->list_info);
-		swstats->mem_freed += nic->config.tx_cfg[i].fifo_len *
+		swstats->mem_freed += tx_cfg->fifo_len *
 			sizeof(struct list_info_hold);
 	}
 
-- 
1.6.3.1.10.g659a0.dirty
