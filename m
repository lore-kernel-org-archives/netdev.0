From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 4/4] ipvs: Document sysctl pmtu_disc
Date: Fri, 17 Feb 2017 14:34:01 +0800
Message-ID: <1487313241-11361-5-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36709 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755649AbdBQGev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 01:34:51 -0500
In-Reply-To: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document sysctl pmtu_disc based on commit 3654e61137db ("ipvs: add pmtu_disc
option to disable IP DF for TUN packets").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ipvs-sysctl.txt | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index e4d9235..fb65d4a 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -175,6 +175,15 @@ nat_icmp_send - BOOLEAN
         for VS/NAT when the load balancer receives packets from real
         servers but the connection entries don't exist.
 
+pmtu_disc - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	When enabled PMTU discovery(default) and received packets larger than
+	the next MTU, we will send back FRAG_NEEDED message and drop the
+	incoming packet. But if users prefer to fragment regardless of DF bit
+	other than drop the packet, they can disable it.
+
 secure_tcp - INTEGER
         0  - disabled (default)
 
-- 
2.5.5
