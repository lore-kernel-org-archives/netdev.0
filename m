From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH 2/2] net: sh_eth: fix the parameter for the ETHER of SH7757
Date: Wed, 06 Jul 2011 15:33:57 +0900
Message-ID: <4E1401D5.60506@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>
To: davem@davemloft.net
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the driver didn't set this parameter on the ETHER, the CPU will
encounter the "data address error" exception.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/sh_eth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index c08d9e1..93b347a 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -139,6 +139,8 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.tpauser	= 1,
 	.hw_swap	= 1,
 	.no_ade		= 1,
+	.rpadir		= 1,
+	.rpadir_value   = 2 << 16,
 };

 #define SH_GIGA_ETH_BASE	0xfee00000
-- 
1.7.1
