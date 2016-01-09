From: =?UTF-8?q?J=CE=B5an=20Sacren?= <sakiwit@gmail.com>
Subject: [PATCH net-next 3/3] openvswitch: update kernel doc for struct vport
Date: Sat,  9 Jan 2016 16:07:11 -0700
Message-ID: <1452380831-11258-4-git-send-email-sakiwit@gmail.com>
Cc: Pravin Shelar <pshelar@nicira.com>, dev@openvswitch.org,
	Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33869 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756247AbcAIXHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 18:07:55 -0500
Received: by mail-pf0-f194.google.com with SMTP id 65so2160490pfd.1
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 15:07:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

commit be4ace6e6b1b ("openvswitch: Move dev pointer into vport itself")

The commit above added @dev and moved @rcu to the bottom of struct
vport, but the change was not reflected in the kernel doc. So let's
update the kernel doc as well.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/vport.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index f00bb153ad13..c10899cb9040 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -70,7 +70,7 @@ struct vport_portids {
 
 /**
  * struct vport - one port within a datapath
- * @rcu: RCU callback head for deferred destruction.
+ * @dev: Pointer to net_device.
  * @dp: Datapath to which this port belongs.
  * @upcall_portids: RCU protected 'struct vport_portids'.
  * @port_no: Index into @dp's @ports array.
@@ -78,6 +78,7 @@ struct vport_portids {
  * @dp_hash_node: Element in @datapath->ports hash table in datapath.c.
  * @ops: Class structure.
  * @detach_list: list used for detaching vport in net-exit call.
+ * @rcu: RCU callback head for deferred destruction.
  */
 struct vport {
 	struct net_device *dev;
