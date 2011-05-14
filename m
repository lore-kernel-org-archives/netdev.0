From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next] net: drivers: kill two unused macro definitions
Date: Sat, 14 May 2011 15:08:47 +0800
Message-ID: <4DCE2A7F.1040000@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: fubar@us.ibm.com, andy@greyhouse.net,
	David Miller <davem@davemloft.net>, jpirko@redhat.com,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Eric Dumazet <eric.dumazet
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50292 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab1ENHIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 03:08:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/bonding/bonding.h |   10 ----------
 drivers/net/veth.c            |    1 -
 2 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index d08362e..ea1d005 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -39,16 +39,6 @@
 	       netif_carrier_ok(dev))
 
 /*
- * Checks whether bond is ready for transmit.
- *
- * Caller must hold bond->lock
- */
-#define BOND_IS_OK(bond)			     \
-		   (((bond)->dev->flags & IFF_UP) && \
-		    netif_running((bond)->dev)	  && \
-		    ((bond)->slave_cnt > 0))
-
-/*
  * Checks whether slave is ready for transmit.
  */
 #define SLAVE_IS_OK(slave)			        \
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 3b0151a..8461576 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -22,7 +22,6 @@
 
 #define MIN_MTU 68		/* Min L3 MTU */
 #define MAX_MTU 65535		/* Max L3 MTU (arbitrary) */
-#define MTU_PAD (ETH_HLEN + 4)  /* Max difference between L2 and L3 size MTU */
 
 struct veth_net_stats {
 	unsigned long	rx_packets;
-- 
1.7.4.1
