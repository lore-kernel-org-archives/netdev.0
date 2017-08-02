From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] X25: constify null_x25_address
Date: Wed,  2 Aug 2017 11:35:00 +0200
Message-ID: <1501666500-25911-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, linux-x25@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

null_x25_address is only used to access the string it contains, so it can
be const.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/x25/af_x25.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 5a1a98d..ac09593 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -74,7 +74,7 @@
 
 static const struct proto_ops x25_proto_ops;
 
-static struct x25_address null_x25_address = {"               "};
+static const struct x25_address null_x25_address = {"               "};
 
 #ifdef CONFIG_COMPAT
 struct compat_x25_subscrip_struct {
