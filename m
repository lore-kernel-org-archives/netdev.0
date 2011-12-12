From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 01/11] batman-adv: report compat_version in version field in case of version mismatch
Date: Mon, 12 Dec 2011 19:31:45 +0800
Message-ID: <1323689516-24427-2-git-send-email-lindner_marek@yahoo.de>
References: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm13.bullet.mail.ukl.yahoo.com ([217.146.183.187]:34975 "HELO
	nm13.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752379Ab1LLLcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 06:32:13 -0500
In-Reply-To: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/icmp_socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index ac3520e..defd692 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -217,7 +217,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 
 	if (icmp_packet->version != COMPAT_VERSION) {
 		icmp_packet->msg_type = PARAMETER_PROBLEM;
-		icmp_packet->ttl = COMPAT_VERSION;
+		icmp_packet->version = COMPAT_VERSION;
 		bat_socket_add_packet(socket_client, icmp_packet, packet_len);
 		goto free_skb;
 	}
-- 
1.7.5.4
