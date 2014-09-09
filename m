From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/3] sit: Add gro callbacks to sit_offload
Date: Tue,  9 Sep 2014 11:23:16 -0700
Message-ID: <1410286996-302-4-git-send-email-therbert@google.com>
References: <1410286996-302-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:55243 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaIISX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:23:57 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so4661946pad.0
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 11:23:56 -0700 (PDT)
In-Reply-To: <1410286996-302-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ipv6_gro_receive and ipv6_gro_complete to sit_offload to
support GRO.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/ip6_offload.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 929bbbcd..9952f3f 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -317,6 +317,8 @@ static const struct net_offload sit_offload = {
 	.callbacks = {
 		.gso_send_check = ipv6_gso_send_check,
 		.gso_segment	= ipv6_gso_segment,
+		.gro_receive	= ipv6_gro_receive,
+		.gro_complete	= ipv6_gro_complete,
 	},
 };
 
-- 
2.1.0.rc2.206.gedb03e5
