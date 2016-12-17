From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: use designated initializers
Date: Fri, 16 Dec 2016 16:58:58 -0800
Message-ID: <20161217005858.GA140223@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36190 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758791AbcLQA7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 19:59:05 -0500
Received: by mail-pf0-f181.google.com with SMTP id 189so16363774pfz.3
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 16:59:04 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare to mark sensitive kernel structures for randomization by making
sure they're using designated initializers. These were identified during
allyesconfig builds of x86, arm, and arm64, with most initializer fixes
extracted from grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/decnet/dn_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index b2c26b081134..41f803e35da3 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -201,7 +201,7 @@ static struct dn_dev_sysctl_table {
 		.extra1 = &min_t3,
 		.extra2 = &max_t3
 	},
-	{0}
+	{ }
 	},
 };
 
-- 
2.7.4


-- 
Kees Cook
Nexus Security
