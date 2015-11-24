From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH] net: openvswitch: Remove invalid comment
Date: Tue, 24 Nov 2015 13:51:53 -0500
Message-ID: <1448391113-18628-1-git-send-email-aconole@bytheb.org>
Cc: Pravin Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34408 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbbKXSwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:52:03 -0500
Received: by qgeb1 with SMTP id b1so17177683qge.1
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 10:52:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During pre-upstream development, the openvswitch datapath used a custom
hashtable to store vports that could fail on delete due to lack of
memory. However, prior to upstream submission, this code was reworked to
use an hlist based hastable with flexible-array based buckets. As such
the failure condition was eliminated from the vport_del path, rendering
this comment invalid.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 net/openvswitch/vport.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 0ac0fd0..e194c10a 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -256,8 +256,8 @@ int ovs_vport_set_options(struct vport *vport, struct nlattr *options)
  *
  * @vport: vport to delete.
  *
- * Detaches @vport from its datapath and destroys it.  It is possible to fail
- * for reasons such as lack of memory.  ovs_mutex must be held.
+ * Detaches @vport from its datapath and destroys it.  ovs_mutex must
+ * be held.
  */
 void ovs_vport_del(struct vport *vport)
 {
-- 
2.6.1.133.gf5b6079
