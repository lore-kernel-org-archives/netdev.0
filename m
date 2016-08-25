From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] devlink: remove unused priv_size
Date: Thu, 25 Aug 2016 16:46:44 +0200
Message-ID: <1472136404-11679-1-git-send-email-ivecera@redhat.com>
Cc: Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50838 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756059AbcHYOz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 10:55:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused and useless priv_size member from struct devlink_ops.

Cc: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 include/net/devlink.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index c99ffe8..211bd3c 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -50,7 +50,6 @@ struct devlink_sb_pool_info {
 };
 
 struct devlink_ops {
-	size_t priv_size;
 	int (*port_type_set)(struct devlink_port *devlink_port,
 			     enum devlink_port_type port_type);
 	int (*port_split)(struct devlink *devlink, unsigned int port_index,
-- 
2.7.3
