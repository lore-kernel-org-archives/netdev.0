From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] lib: Allow compile-testing of parman
Date: Fri, 24 Feb 2017 11:25:55 +0100
Message-ID: <1487931955-31381-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows to enable and run the accompanying test (test_parman)
without dependencies on other users of parman.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 lib/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/Kconfig b/lib/Kconfig
index fe7e8e175db8f7b4..e494065156a28d20 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -549,7 +549,7 @@ config SBITMAP
 	bool
 
 config PARMAN
-	tristate
+	tristate "parman" if COMPILE_TEST
 
 config PRIME_NUMBERS
 	tristate
-- 
2.7.4
