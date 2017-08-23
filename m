From: William Tu <u9012063@gmail.com>
Subject: [trivial] gre: fix goto statement typo
Date: Tue, 22 Aug 2017 17:04:05 -0700
Message-ID: <1503446645-33652-1-git-send-email-u9012063@gmail.com>
Cc: trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34516 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752533AbdHWAEU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 20:04:20 -0400
Received: by mail-pf0-f195.google.com with SMTP id m6so188780pfm.1
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 17:04:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix typo: pnet_tap_faied.

Signed-off-by: William Tu <u9012063@gmail.com>
---
 net/ipv4/ip_gre.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6e8a62289e03..5a20ba9b9b50 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1467,7 +1467,7 @@ static int __init ipgre_init(void)
 
 	err = register_pernet_device(&ipgre_tap_net_ops);
 	if (err < 0)
-		goto pnet_tap_faied;
+		goto pnet_tap_failed;
 
 	err = register_pernet_device(&erspan_net_ops);
 	if (err < 0)
@@ -1503,7 +1503,7 @@ static int __init ipgre_init(void)
 	unregister_pernet_device(&erspan_net_ops);
 pnet_erspan_failed:
 	unregister_pernet_device(&ipgre_tap_net_ops);
-pnet_tap_faied:
+pnet_tap_failed:
 	unregister_pernet_device(&ipgre_net_ops);
 	return err;
 }
-- 
2.7.4
