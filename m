From: Daniel Axtens <dja@axtens.net>
Subject: [PATCH] openvswitch: fix mis-ordered comment lines for ovs_skb_cb
Date: Mon,  3 Jul 2017 21:46:43 +1000
Message-ID: <20170703114643.3441-1-dja@axtens.net>
Cc: Daniel Axtens <dja@axtens.net>
To: pshelar@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34971 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752625AbdGCLrQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 07:47:16 -0400
Received: by mail-pg0-f66.google.com with SMTP id d193so4615945pgc.2
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 04:47:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was trying to wrap my head around meaning of mru, and realised
that the second line of the comment defining it had somehow
ended up after the line defining cutlen, leading to much confusion.

Reorder the lines to make sense.

Signed-off-by: Daniel Axtens <dja@axtens.net>
---
 net/openvswitch/datapath.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index da931bdef8a7..5d8dcd88815f 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -98,8 +98,8 @@ struct datapath {
  * @input_vport: The original vport packet came in on. This value is cached
  * when a packet is received by OVS.
  * @mru: The maximum received fragement size; 0 if the packet is not
- * @cutlen: The number of bytes from the packet end to be removed.
  * fragmented.
+ * @cutlen: The number of bytes from the packet end to be removed.
  */
 struct ovs_skb_cb {
 	struct vport		*input_vport;
-- 
2.11.0
