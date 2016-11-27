From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH net-next] net/sched: Export tc_tunnel_key so its UAPI accessible
Date: Sun, 27 Nov 2016 12:07:13 +0200
Message-ID: <1480241233-50097-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Roi Dayan <roid@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54042 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753358AbcK0KHb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 05:07:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export tc_tunnel_key so it can be used from user space.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Amir Vadai <amir@vadai.me>
---
 include/uapi/linux/tc_act/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index e3969bd..9611c7b 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -11,3 +11,4 @@ header-y += tc_vlan.h
 header-y += tc_bpf.h
 header-y += tc_connmark.h
 header-y += tc_ife.h
+header-y += tc_tunnel_key.h
-- 
2.7.4
