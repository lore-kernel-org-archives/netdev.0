From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH  8/12] NET/ROM has no txqueue
Date: Sun, 11 Sep 2005 23:19:22 +0100
Message-ID: <20050911221922.GA9322@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET/ROM uses virtual interfaces so setting a queue length is wrong.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/netrom/nr_dev.c |    1 -
 1 files changed, 1 deletion(-)

Index: net-2.6.git/net/netrom/nr_dev.c
===================================================================
--- net-2.6.git.orig/net/netrom/nr_dev.c
+++ net-2.6.git/net/netrom/nr_dev.c
@@ -194,7 +194,6 @@ void nr_setup(struct net_device *dev)
 	dev->hard_header_len	= NR_NETWORK_LEN + NR_TRANSPORT_LEN;
 	dev->addr_len		= AX25_ADDR_LEN;
 	dev->type		= ARPHRD_NETROM;
-	dev->tx_queue_len	= 40;
 	dev->rebuild_header	= nr_rebuild_header;
 	dev->set_mac_address    = nr_set_mac_address;
 
