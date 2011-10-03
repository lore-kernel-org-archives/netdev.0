From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 04/11] Fix wrong sanity check in choke_parse_opt()
Date: Mon, 03 Oct 2011 17:23:18 +0200
Message-ID: <4E89D366.3060009@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:39571 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756489Ab1JCP0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:26:15 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by re04.intra2net.com (Postfix) with ESMTP id 6451830154
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:14 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id 36C632AC58
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:14 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id 47F7A2AC57
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:13 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 tc/q_choke.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/q_choke.c b/tc/q_choke.c
index 6e54cb7..04a864f 100644
--- a/tc/q_choke.c
+++ b/tc/q_choke.c
@@ -122,7 +122,7 @@ static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		return -1;
 	}
 
-	if (opt.qth_min > opt.qth_min) {
+	if (opt.qth_min >= opt.qth_max) {
 		fprintf(stderr, "\"min\" is not smaller than \"max\"\n");
 		return -1;
 	}
-- 
1.7.4.4
