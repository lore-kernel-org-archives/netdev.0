From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] lib: Remove string from parman config selection
Date: Thu, 23 Feb 2017 10:57:45 +0100
Message-ID: <1487843865-2253-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, geert@linux-m68k.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34710 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdBWJ5y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 04:57:54 -0500
Received: by mail-wr0-f195.google.com with SMTP id 89so3288097wrr.1
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 01:57:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As reported by Geert, remove the string so the user does not see this
config option. The option is explicitly selected only as a dependency of
in-kernel users.

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Fixes: 44091d29f207 ("lib: Introduce priority array area manager")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 lib/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/Kconfig b/lib/Kconfig
index 5d644f1..f355260 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -551,6 +551,6 @@ config SBITMAP
 	bool
 
 config PARMAN
-	tristate "parman"
+	tristate
 
 endmenu
-- 
2.7.4
