From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH net-next v9 8/9] net: openvswitch - set name assign type
Date: Thu, 17 Jul 2014 10:06:09 +0200
Message-ID: <1405584370-30054-9-git-send-email-teg@jklm.no>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>,
	Pravin Shelar <pshelar@nicira.com>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405584370-30054-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Pravin Shelar <pshelar@nicira.com>
Cc: dev@openvswitch.org
---

v9: set NET_NAME_USER directly in internal_dev_create as requested by Pravin Shelar

 net/openvswitch/vport-internal_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index bd65855..2741285 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -165,7 +165,7 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 	netdev_vport = netdev_vport_priv(vport);
 
 	netdev_vport->dev = alloc_netdev(sizeof(struct internal_dev),
-					 parms->name, NET_NAME_UNKNOWN,
+					 parms->name, NET_NAME_USER,
 					 do_setup);
 	if (!netdev_vport->dev) {
 		err = -ENOMEM;
-- 
1.9.3
