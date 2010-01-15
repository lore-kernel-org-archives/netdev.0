From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH] macvlan: add GRO bit to features mask
Date: Fri, 15 Jan 2010 15:00:51 -0500
Message-ID: <20100115200039.10618.8232.stgit@mimic.site>
References: <4B503E86.8010603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	kaber@trash.net, arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4B503E86.8010603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow macvlan devices to support GRO.

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>

Acked-by: Patrick McHardy <kaber@trash.net>
---

 drivers/net/macvlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0a389b8..94bb135 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -316,7 +316,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
-	 NETIF_F_TSO_ECN | NETIF_F_TSO6)
+	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO)
 
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))

