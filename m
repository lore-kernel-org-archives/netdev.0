From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/7] socket: make sockfs_setattr static
Date: Tue, 10 Jan 2017 10:18:12 -0800
Message-ID: <20170110181816.18991-4-sthemmin@microsoft.com>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34173 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939982AbdAJSS2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:18:28 -0500
Received: by mail-pf0-f181.google.com with SMTP id 127so50803995pfg.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:18:28 -0800 (PST)
In-Reply-To: <20170110181816.18991-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warning introduced by commit ead05568c7d5e
("net: core: Add a UID field to struct sock.")

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index 3ef02e97ecf3..b7a63d5bc915 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -531,7 +531,7 @@ static ssize_t sockfs_listxattr(struct dentry *dentry, char *buffer,
 	return used;
 }
 
-int sockfs_setattr(struct dentry *dentry, struct iattr *iattr)
+static int sockfs_setattr(struct dentry *dentry, struct iattr *iattr)
 {
 	int err = simple_setattr(dentry, iattr);
 
-- 
2.11.0
