From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/5] sit: Add gro callbacks to sit offload
Date: Sun,  7 Sep 2014 22:26:27 -0700
Message-ID: <1410153989-23837-4-git-send-email-therbert@google.com>
References: <1410153989-23837-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:54364 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaIHF1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 01:27:12 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so1057894pab.15
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 22:27:11 -0700 (PDT)
In-Reply-To: <1410153989-23837-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ip6_gro_receive and inet_gro_complete to ip6_offload to
support GRO.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/ip6_offload.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 5bcda33..12a686f 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -314,6 +314,8 @@ static const struct net_offload sit_offload = {
 	.callbacks = {
 		.gso_send_check = ipv6_gso_send_check,
 		.gso_segment	= ipv6_gso_segment,
+		.gro_receive	= ipv6_gro_receive,
+		.gro_complete	= ipv6_gro_complete,
 	},
 };
 
-- 
2.1.0.rc2.206.gedb03e5
