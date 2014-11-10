From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/6] openvswitch: Export symbols as GPL symbols.
Date: Sun,  9 Nov 2014 19:59:03 -0800
Message-ID: <1415591943-1564-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:56962 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752083AbaKJD7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:59:08 -0500
Received: by mail-pd0-f176.google.com with SMTP id ft15so6968483pdb.21
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:59:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vport can be compiled as modules, therefore openvswitch needs
to export few symbols. Export them as GPL symbols.

CC: Thomas Graf <tgraf@noironetworks.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c |  4 ++--
 net/openvswitch/vport.c    | 12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 014485e..6cfb44f 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -59,7 +59,7 @@
 #include "vport-netdev.h"
 
 int ovs_net_id __read_mostly;
-EXPORT_SYMBOL(ovs_net_id);
+EXPORT_SYMBOL_GPL(ovs_net_id);
 
 static struct genl_family dp_packet_genl_family;
 static struct genl_family dp_flow_genl_family;
@@ -131,7 +131,7 @@ int lockdep_ovsl_is_held(void)
 	else
 		return 1;
 }
-EXPORT_SYMBOL(lockdep_ovsl_is_held);
+EXPORT_SYMBOL_GPL(lockdep_ovsl_is_held);
 #endif
 
 static struct vport *new_vport(const struct vport_parms *);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 8168ef0..4b5dd18 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -90,7 +90,7 @@ errout:
 	ovs_unlock();
 	return err;
 }
-EXPORT_SYMBOL(ovs_vport_ops_register);
+EXPORT_SYMBOL_GPL(ovs_vport_ops_register);
 
 void ovs_vport_ops_unregister(struct vport_ops *ops)
 {
@@ -98,7 +98,7 @@ void ovs_vport_ops_unregister(struct vport_ops *ops)
 	list_del(&ops->list);
 	ovs_unlock();
 }
-EXPORT_SYMBOL(ovs_vport_ops_unregister);
+EXPORT_SYMBOL_GPL(ovs_vport_ops_unregister);
 
 /**
  *	ovs_vport_locate - find a port that has already been created
@@ -165,7 +165,7 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 
 	return vport;
 }
-EXPORT_SYMBOL(ovs_vport_alloc);
+EXPORT_SYMBOL_GPL(ovs_vport_alloc);
 
 /**
  *	ovs_vport_free - uninitialize and free vport
@@ -186,7 +186,7 @@ void ovs_vport_free(struct vport *vport)
 	free_percpu(vport->percpu_stats);
 	kfree(vport);
 }
-EXPORT_SYMBOL(ovs_vport_free);
+EXPORT_SYMBOL_GPL(ovs_vport_free);
 
 static struct vport_ops *ovs_vport_lookup(const struct vport_parms *parms)
 {
@@ -493,7 +493,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	}
 	ovs_dp_process_packet(skb, &key);
 }
-EXPORT_SYMBOL(ovs_vport_receive);
+EXPORT_SYMBOL_GPL(ovs_vport_receive);
 
 /**
  *	ovs_vport_send - send a packet on a device
@@ -572,4 +572,4 @@ void ovs_vport_deferred_free(struct vport *vport)
 
 	call_rcu(&vport->rcu, free_vport_rcu);
 }
-EXPORT_SYMBOL(ovs_vport_deferred_free);
+EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
-- 
1.9.3
