From: Eric Engestrom <eric.engestrom@imgtec.com>
Subject: [PATCH] net-sysfs: remove left over dead code
Date: Mon, 29 Feb 2016 16:34:25 +0000
Message-ID: <1456763665-499-1-git-send-email-eric.engestrom@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Engestrom <eric.engestrom@imgtec.com>
To: "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	David Ahern <dsahern@gmail.com>,
	Alexander Stein <alexander.stein@systec-electronic.com>,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Tom Herbert <tom@herbertland.com>,
	Sasha Levin <sasha.levin@oracle.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:56516 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbcB2QeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 11:34:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This format hasn't been used since 04ed3e741d0f133e02bed7fa5c98edba128f90e7
("net: change netdev->features to u32")

Signed-off-by: Eric Engestrom <eric.engestrom@imgtec.com>
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
2.7.1
