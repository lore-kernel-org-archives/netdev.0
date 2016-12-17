From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/x25: use designated initializers
Date: Fri, 16 Dec 2016 17:03:39 -0800
Message-ID: <20161217010339.GA140529@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Hendry <andrew.hendry@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, linux-x25@vger.kernel.org,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33164 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422678AbcLQBDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 20:03:41 -0500
Received: by mail-pf0-f172.google.com with SMTP id d2so16395819pfd.0
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 17:03:41 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare to mark sensitive kernel structures for randomization by making
sure they're using designated initializers. These were identified during
allyesconfig builds of x86, arm, and arm64, with most initializer fixes
extracted from grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/x25/sysctl_net_x25.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/x25/sysctl_net_x25.c b/net/x25/sysctl_net_x25.c
index 43239527a205..a06dfe143c67 100644
--- a/net/x25/sysctl_net_x25.c
+++ b/net/x25/sysctl_net_x25.c
@@ -70,7 +70,7 @@ static struct ctl_table x25_table[] = {
 		.mode = 	0644,
 		.proc_handler = proc_dointvec,
 	},
-	{ 0, },
+	{ },
 };
 
 void __init x25_register_sysctl(void)
-- 
2.7.4


-- 
Kees Cook
Nexus Security
