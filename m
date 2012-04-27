From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH net-next] net: doc: merge /proc/sys/net/core/* documents into
 one place
Date: Fri, 27 Apr 2012 10:52:52 +0800
Message-ID: <4F9A0A04.7090703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:37402 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758110Ab2D0CwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 22:52:05 -0400
Received: by dadz8 with SMTP id z8so354138dad.10
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 19:52:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <davidshan@tencent.com>

All parameter descriptions in /proc/sys/net/core/* now is separated
two places. So, merge them into Documentation/sysctl/net.txt.


Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 Documentation/networking/ip-sysctl.txt |    5 +----
 Documentation/sysctl/net.txt           |    7 +++++++
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index bd80ba5..9b569a2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1484,11 +1484,8 @@ addr_scope_policy - INTEGER
 
 
 /proc/sys/net/core/*
-dev_weight - INTEGER
-	The maximum number of packets that kernel can handle on a NAPI
-	interrupt, it's a Per-CPU variable.
+	Please see: Documentation/sysctl/net.txt for descriptions of these entries.
 
-	Default: 64
 
 /proc/sys/net/unix/*
 max_dgram_qlen - INTEGER
diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 3201a70..98335b7 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -43,6 +43,13 @@ Values :
 	1 - enable the JIT
 	2 - enable the JIT and ask the compiler to emit traces on kernel log.
 
+dev_weight
+--------------
+
+The maximum number of packets that kernel can handle on a NAPI interrupt,
+it's a Per-CPU variable.
+Default: 64
+
 rmem_default
 ------------
 
-- 
1.7.1
