From: Luca Lemmo <luca@linux.com>
Subject: [PATCH 1/3] tc: f_u32: add missing spaces around operators
Date: Wed, 16 Mar 2016 17:56:12 +0100
Message-ID: <1458147374-8899-1-git-send-email-luca@linux.com>
Cc: netdev@vger.kernel.org, Luca Lemmo <luca@linux.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52180 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752890AbcCPQ4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 12:56:55 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 32ACC209CE
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 12:56:54 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Luca Lemmo <luca@linux.com>
---
 tc/f_u32.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 0b97678..2a6c971 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -47,7 +47,7 @@ static void explain(void)
 
 static int get_u32_handle(__u32 *handle, const char *str)
 {
-	__u32 htid=0, hash=0, nodeid=0;
+	__u32 htid = 0, hash = 0, nodeid = 0;
 	char *tmp = strchr(str, ':');
 
 	if (tmp == NULL) {
@@ -58,21 +58,21 @@ static int get_u32_handle(__u32 *handle, const char *str)
 	htid = strtoul(str, &tmp, 16);
 	if (tmp == str && *str != ':' && *str != 0)
 		return -1;
-	if (htid>=0x1000)
+	if (htid >= 0x1000)
 		return -1;
 	if (*tmp) {
 		str = tmp + 1;
 		hash = strtoul(str, &tmp, 16);
 		if (tmp == str && *str != ':' && *str != 0)
 			return -1;
-		if (hash>=0x100)
+		if (hash >= 0x100)
 			return -1;
 		if (*tmp) {
 			str = tmp + 1;
 			nodeid = strtoul(str, &tmp, 16);
 			if (tmp == str && *str != 0)
 				return -1;
-			if (nodeid>=0x1000)
+			if (nodeid >= 0x1000)
 				return -1;
 		}
 	}
@@ -122,7 +122,7 @@ static int pack_key(struct tc_u32_sel *sel, __u32 key, __u32 mask,
 
 	key &= mask;
 
-	for (i=0; i<hwm; i++) {
+	for (i = 0; i < hwm; i++) {
 		if (sel->keys[i].off == off && sel->keys[i].offmask == offmask) {
 			__u32 intersect = mask & sel->keys[i].mask;
 
@@ -1244,7 +1244,7 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 	if (sel) {
 		if (sel->nkeys) {
 			int i;
-			for (i=0; i<sel->nkeys; i++) {
+			for (i = 0; i < sel->nkeys; i++) {
 				show_keys(f, sel->keys + i);
 				if (show_stats && NULL != pf)
 					fprintf(f, " (success %llu ) ",
-- 
2.7.3
