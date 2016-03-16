From: Luca Lemmo <luca@linux.com>
Subject: [PATCH 2/3] tc: f_u32: trivial coding style cleanups
Date: Wed, 16 Mar 2016 17:56:13 +0100
Message-ID: <1458147374-8899-2-git-send-email-luca@linux.com>
References: <1458147374-8899-1-git-send-email-luca@linux.com>
Cc: netdev@vger.kernel.org, Luca Lemmo <luca@linux.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:43135 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933379AbcCPQ5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 12:57:18 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id BA6AE20A45
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 12:57:17 -0400 (EDT)
In-Reply-To: <1458147374-8899-1-git-send-email-luca@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Luca Lemmo <luca@linux.com>
---
 tc/f_u32.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 2a6c971..5ca60c8 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -80,7 +80,7 @@ static int get_u32_handle(__u32 *handle, const char *str)
 	return 0;
 }
 
-static char * sprint_u32_handle(__u32 handle, char *buf)
+static char *sprint_u32_handle(__u32 handle, char *buf)
 {
 	int bsize = SPRINT_BSIZE-1;
 	__u32 htid = TC_U32_HTID(handle);
@@ -382,7 +382,7 @@ static int parse_ip6_addr(int *argc_p, char ***argv_p,
 
 	plen = addr.bitlen;
 	for (i = 0; i < plen; i += 32) {
-//		if (((i + 31) & ~0x1F) <= plen) {
+		/* if (((i + 31) & ~0x1F) <= plen) { */
 		if (i + 31 <= plen) {
 			res = pack_key(sel, addr.data[i / 32],
 				       0xFFFFFFFF, off + 4 * (i / 32), offmask);
@@ -1109,14 +1109,14 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 			continue;
 		} else if (strcmp(*argv, "indev") == 0) {
 			char ind[IFNAMSIZ + 1];
-			memset(ind, 0, sizeof (ind));
+			memset(ind, 0, sizeof(ind));
 			argc--;
 			argv++;
 			if (argc < 1) {
 				fprintf(stderr, "Illegal indev\n");
 				return -1;
 			}
-			strncpy(ind, *argv, sizeof (ind) - 1);
+			strncpy(ind, *argv, sizeof(ind) - 1);
 			addattr_l(n, MAX_MSG, TCA_U32_INDEV, ind, strlen(ind) + 1);
 
 		} else if (matches(*argv, "action") == 0) {
-- 
2.7.3
