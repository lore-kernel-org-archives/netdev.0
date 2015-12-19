From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Subject: [PATCH 2/2] [iproute2] tc/q_htb.c: rename b4 buffer to b3 to make its  name more consistent
Date: Sat, 19 Dec 2015 18:26:03 +0300
Message-ID: <3134971450538763@web30j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward20j.cmail.yandex.net ([5.255.227.239]:40128 "EHLO
	forward20j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933222AbbLSP0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2015 10:26:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

b3 buffer has been deleted previously so b2 is followed by b4 which is not consistent

Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Phil Sutter <phil@nwl.cc>
---
 tc/q_htb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/q_htb.c b/tc/q_htb.c
index e76d20a..7d54090 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -273,7 +273,7 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	__u64 rate64, ceil64;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
-	SPRINT_BUF(b4);
+	SPRINT_BUF(b3);
 
 	if (opt == NULL)
 		return 0;
@@ -310,7 +310,7 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		cbuffer = tc_calc_xmitsize(ceil64, hopt->cbuffer);
 		linklayer = (hopt->rate.linklayer & TC_LINKLAYER_MASK);
 		if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
-			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b4));
+			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b3));
 		if (show_details) {
 			fprintf(f, "burst %s/%u mpu %s ",
 				sprint_size(buffer, b1),
-- 
2.5.0
