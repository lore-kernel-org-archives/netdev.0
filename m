From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH 1/1] net sysfs: Print link speed as signed integer
Date: Mon, 28 Sep 2015 14:48:49 +0200
Message-ID: <1443444529-12868-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: Alexander Stein <alexander.stein@systec-electronic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Otherwise 4294967295 (MBit/s) (-1) will be printed when there is no link.
Documentation/ABI/testing/sysfs-class-net does not state if this shall be
signed or unsigned.

Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---
 net/core/net-sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 805a95a..e3f7eea 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -31,7 +31,7 @@
 static const char fmt_hex[] = "%#x\n";
 static const char fmt_long_hex[] = "%#lx\n";
 static const char fmt_dec[] = "%d\n";
-static const char fmt_udec[] = "%u\n";
+static const char fmt_udec[] = "%d\n";
 static const char fmt_ulong[] = "%lu\n";
 static const char fmt_u64[] = "%llu\n";
 
-- 
2.4.9
