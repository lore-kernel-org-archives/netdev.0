From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 3/3] net: stmmac: Use AVB mode by default
Date: Tue, 21 Mar 2017 16:12:11 +0100
Message-ID: <20170321151211.31841-3-thierry.reding@gmail.com>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        LABBE Corentin <clabbe.montjoie@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170321151211.31841-1-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Prior to the recent multi-queue changes the driver would configure the
queues to use the AVB mode, but the mode then got switched to DCB. The
hardware still works fine in DCB mode, but my testing capabilities are
limited, so it's safer to revert to the prior setting anyway.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 include/linux/stmmac.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index be47b859e954..8349a5c1537b 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -56,8 +56,8 @@
 #define MTL_RX_ALGORITHM_WSP	0x5
 
 /* RX/TX Queue Mode */
-#define MTL_QUEUE_DCB		0x0
-#define MTL_QUEUE_AVB		0x1
+#define MTL_QUEUE_AVB		0x0
+#define MTL_QUEUE_DCB		0x1
 
 /* The MDC clock could be set higher than the IEEE 802.3
  * specified frequency limit 0f 2.5 MHz, by programming a clock divider
-- 
2.12.0
