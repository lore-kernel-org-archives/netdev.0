From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] net: bridge: add the multicast_flood flag attribute to brport_attrs
Date: Thu, 13 Oct 2016 15:20:52 +0200
Message-ID: <1476364852-25777-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:36030 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753788AbcJMNWb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 09:22:31 -0400
Received: by mail-vk0-f52.google.com with SMTP id 2so77208092vkb.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 06:21:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I added the multicast flood control flag, I also added an attribute
for it for sysfs similar to other flags, but I forgot to add it to
brport_attrs.

Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_sysfs_if.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index e657258e1f2c..8bd569695e76 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -217,6 +217,7 @@ static const struct brport_attribute *brport_attrs[] = {
 #endif
 	&brport_attr_proxyarp,
 	&brport_attr_proxyarp_wifi,
+	&brport_attr_multicast_flood,
 	NULL
 };
 
-- 
2.1.4
