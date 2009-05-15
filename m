From: Wang Tinggong <wangtinggong@gmail.com>
Subject: [PATCH] Doc: fixed descriptions on /proc/sys/net/core/* and
	/proc/sys/net/unix/*
Date: Fri, 15 May 2009 16:49:36 +0800
Message-ID: <20090515084936.GA11099@rosicky>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: trivial@kernel.org, netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f123.google.com ([209.85.216.123]:36445 "EHLO
	mail-px0-f123.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664AbZEOItb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 04:49:31 -0400
Received: by pxi29 with SMTP id 29so942468pxi.33
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 01:49:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Wang Tinggong <wangtinggong@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ec5de02..b121c5d 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1266,13 +1266,22 @@ sctp_rmem - vector of 3 INTEGERs: min, default, max
 sctp_wmem  - vector of 3 INTEGERs: min, default, max
 	See tcp_wmem for a description.
 
-UNDOCUMENTED:
 
 /proc/sys/net/core/*
-	dev_weight FIXME
+dev_weight - INTEGER
+	The maximum number of packets that kernel can handle on a NAPI
+	interrupt, it's a Per-CPU variable.
+
+	Default: 64
 
 /proc/sys/net/unix/*
-	max_dgram_qlen FIXME
+max_dgram_qlen - INTEGER
+	The maximum length of dgram socket receive queue
+
+	Default: 10
+
+
+UNDOCUMENTED:
 
 /proc/sys/net/irda/*
 	fast_poll_increase FIXME
-- 
1.6.0
