From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] doc: Clarify behavior when sysctl tcp_ecn = 1
Date: Wed,  9 Jan 2013 14:21:30 -0800
Message-ID: <1357770090-29253-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com, rick.jones2@hp.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:48552 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756709Ab3AIWRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 17:17:13 -0500
Received: by mail-pb0-f47.google.com with SMTP id un1so1216866pbc.34
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 14:17:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent commit (commit 7e3a2dc52953 doc: make the description of how tcp_ecn
works more explicit and clear ) clarified the behavior of tcp_ecn sysctl
variable but description is inconsistent. When requested by incoming conections,
ECN is enabled with not just tcp_ecn = 2 but also with tcp_ecn = 1.

This patch makes it clear that with tcp_ecn = 1, ECN is enabled when requested
by incoming connections.

Also fix spelling of 'incoming'.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index dd52d51..51dcd52 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -214,8 +214,9 @@ tcp_ecn - INTEGER
 	congestion before having to drop packets.
 	Possible values are:
 		0 Disable ECN.  Neither initiate nor accept ECN.
-		1 Always request ECN on outgoing connection attempts.
-		2 Enable ECN when requested by incomming connections
+		1 Enable ECN when requested by incoming connections and
+		  also request ECN on outgoing connection attempts.
+		2 Enable ECN when requested by incoming connections
 		  but do not request ECN on outgoing connections.
 	Default: 2
 
-- 
1.7.0.4
