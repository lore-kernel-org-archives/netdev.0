From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 2/4] ipvs: Document sysctl sync_qlen_max and sync_sock_size
Date: Fri, 17 Feb 2017 14:33:59 +0800
Message-ID: <1487313241-11361-3-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35533 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755562AbdBQGel (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 01:34:41 -0500
In-Reply-To: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document sysctl sync_qlen_max and sync_sock_size based on commit
1c003b1580e2 ("ipvs: wakeup master thread").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ipvs-sysctl.txt | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 7acaaa6..7622ba5 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -217,6 +217,19 @@ sync_retries - INTEGER
 	to protect against loss of sync messages. The range of the
 	sync_retries is from 0 to 3.
 
+sync_qlen_max - UNSIGNED LONG
+
+	Hard limit for queued sync messages that not sent yet. It defaults to
+	1/32 of the memory pages but actually represents number of messages.
+	It will protect us from allocating large parts of memory when the
+	sending rate is lower than the queuing rate.
+
+sync_sock_size - INTEGER
+	default 0
+
+	Configuration of SNDBUF (master) or RCVBUF (slave) socket limit.
+	Default value is 0 (preserve system defaults).
+
 snat_reroute - BOOLEAN
 	0 - disabled
 	not 0 - enabled (default)
-- 
2.5.5
