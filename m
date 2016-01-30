From: Lucas Tanure <tanure@linux.com>
Subject: [PATCH 3/4] netfilter: ipv4: use preferred kernel types
Date: Sat, 30 Jan 2016 11:17:57 -0200
Message-ID: <1454159878-20706-3-git-send-email-tanure@linux.com>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:34806 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbcA3NSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 08:18:11 -0500
In-Reply-To: <1454159878-20706-1-git-send-email-tanure@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by checkpatch.pl:
CHECK: Prefer kernel type 'uX' over 'uintX_t'

Signed-off-by: Lucas Tanure <tanure@linux.com>
---
 net/ipv4/netfilter/ip_tables.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 79d4a04..dcc61c0 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1411,7 +1411,7 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 {
 	struct xt_entry_target *t;
 	struct compat_ipt_entry __user *ce;
-	u_int16_t target_offset, next_offset;
+	u16 target_offset, next_offset;
 	compat_uint_t origsize;
 	const struct xt_entry_match *ematch;
 	int ret = 0;
@@ -2122,8 +2122,7 @@ EXPORT_SYMBOL(ipt_unregister_table);
 
 /* Returns 1 if the type and code is matched by the range, 0 otherwise */
 static inline bool
-icmp_type_code_match(u_int8_t test_type, u_int8_t min_code, u_int8_t max_code,
-		     u_int8_t type, u_int8_t code,
+icmp_type_code_match(u8 test_type, u8 min_code, u8 max_code, u8 type, u8 code,
 		     bool invert)
 {
 	return ((test_type == 0xFF) ||
-- 
2.7.0
