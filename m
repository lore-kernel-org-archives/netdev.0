From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH  9/12] NET/ROM has no ARP
Date: Sun, 11 Sep 2005 23:19:27 +0100
Message-ID: <20050911221927.GA9329@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ARP over NET/ROM does not exist so it's obviously not implemented on any
NET/ROM stack, so the NET/ROM interfaces really should default to IFF_NOARP.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/netrom/nr_dev.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-cvs/net/netrom/nr_dev.c
===================================================================
--- linux-cvs.orig/net/netrom/nr_dev.c
+++ linux-cvs/net/netrom/nr_dev.c
@@ -191,7 +191,7 @@ void nr_setup(struct net_device *dev)
 	dev->set_mac_address    = nr_set_mac_address;
 
 	/* New-style flags. */
-	dev->flags		= 0;
+	dev->flags		= IFF_NOARP;
 
 	dev->get_stats 		= nr_get_stats;
 }
