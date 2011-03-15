From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: [PATCH] Fix overflow of name in struct net_device, replaced sprintf with snprintf.
Date: Wed, 16 Mar 2011 01:30:08 +0530
Message-ID: <1300219208-2708-1-git-send-email-sasikanth.v19@gmail.com>
Cc: netdev@vger.kernel.org, Sasikanth V <sasikanth.v19@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:34586 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757228Ab1COUAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 16:00:19 -0400
Received: by qwk3 with SMTP id 3so773944qwk.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 13:00:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6561021..a74efa9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -539,7 +539,7 @@ unsigned long netdev_boot_base(const char *prefix, int unit)
 	char name[IFNAMSIZ];
 	int i;
 
-	sprintf(name, "%s%d", prefix, unit);
+	snprintf(name, IFNAMSIZ, "%s%d", prefix, unit);
 
 	/*
 	 * If device already registered then return base of 1
-- 
1.7.3.4

