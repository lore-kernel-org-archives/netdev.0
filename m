From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH] openvswitch: use alias for genetlink family names
Date: Fri,  9 Sep 2016 17:42:30 -0300
Message-ID: <1473453750-18854-1-git-send-email-cascardo@redhat.com>
Cc: netdev@vger.kernel.org
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33430 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754432AbcIIUmk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 16:42:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When userspace tries to create datapaths and the module is not loaded,
it will simply fail. With this patch, the module will be automatically
loaded.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
---
 net/openvswitch/datapath.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 524c0fd..0536ab3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -2437,3 +2437,7 @@ module_exit(dp_cleanup);
 
 MODULE_DESCRIPTION("Open vSwitch switching datapath");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_GENL_FAMILY(OVS_DATAPATH_FAMILY);
+MODULE_ALIAS_GENL_FAMILY(OVS_VPORT_FAMILY);
+MODULE_ALIAS_GENL_FAMILY(OVS_FLOW_FAMILY);
+MODULE_ALIAS_GENL_FAMILY(OVS_PACKET_FAMILY);
-- 
2.7.4
