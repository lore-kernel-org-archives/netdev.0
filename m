From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 2/3] macvlan: add GRO bit to features mask
Date: Thu, 14 Jan 2010 16:53:10 -0500
Message-ID: <20100114215310.4958.46657.stgit@mimic.site>
References: <20100114215058.4958.87746.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net, arnd@arndb.de,
	netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932383Ab0ANVx5@vger.kernel.org>
In-Reply-To: <20100114215058.4958.87746.stgit@mimic.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow macvlan devices to support GRO.

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
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
