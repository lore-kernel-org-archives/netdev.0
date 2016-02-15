From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net-sysfs: remove unused fmt_long_hex
Date: Mon, 15 Feb 2016 22:54:47 +0000
Message-ID: <1455576887-12157-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Ever since commit 04ed3e741d0f133e02bed7fa5c98edba128f90e7
("net: change netdev->features to u32") the format string
fmt_long_hex has not been used, so we may as well remove it.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/core/net-sysfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b6c8a66..e326707 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -29,7 +29,6 @@
 
 #ifdef CONFIG_SYSFS
 static const char fmt_hex[] = "%#x\n";
-static const char fmt_long_hex[] = "%#lx\n";
 static const char fmt_dec[] = "%d\n";
 static const char fmt_ulong[] = "%lu\n";
 static const char fmt_u64[] = "%llu\n";
-- 
2.7.0
