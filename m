From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] rtnetlink: Add dump all for netconf
Date: Tue, 21 Mar 2017 12:22:26 -0700
Message-ID: <1490124146-7021-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34445 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933433AbdCUT2w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 15:28:52 -0400
Received: by mail-pg0-f49.google.com with SMTP id 21so64866482pgg.1
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 12:28:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the rtnl_dump_all to dump all netconf handlers that have been
registered. Allows userspace to send a dump request for PF_UNSPEC
and get all families.

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c4e84c558240..9c3947a43eff 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4185,6 +4185,7 @@ void __init rtnetlink_init(void)
 
 	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all, NULL);
 	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETNETCONF, NULL, rtnl_dump_all, NULL);
 
 	rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, rtnl_fdb_add, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_DELNEIGH, rtnl_fdb_del, NULL, NULL);
-- 
2.1.4
