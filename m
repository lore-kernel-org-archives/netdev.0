From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next] gre6: Clean up unused struct ipv6_tel_txoption definition
Date: Fri, 20 Jan 2017 14:53:06 +0100
Message-ID: <1484920386-9058-1-git-send-email-jkbs@redhat.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36891 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752214AbdATNxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 08:53:10 -0500
Received: by mail-wm0-f45.google.com with SMTP id c206so44529167wme.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 05:53:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b05229f44228 ("gre6: Cleanup GREv6 transmit path, call common GRE
functions") removed the ip6gre specific transmit function, but left the
struct ipv6_tel_txoption definition. Clean it up.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 net/ipv6/ip6_gre.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 75b6108..65bdfd1 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -484,11 +484,6 @@ static int gre_rcv(struct sk_buff *skb)
 	return 0;
 }
 
-struct ipv6_tel_txoption {
-	struct ipv6_txoptions ops;
-	__u8 dst_opt[8];
-};
-
 static int gre_handle_offloads(struct sk_buff *skb, bool csum)
 {
 	return iptunnel_handle_offloads(skb,
-- 
2.7.4
