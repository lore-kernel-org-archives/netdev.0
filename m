From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 03/11] Fix wrong comparison in cmp_print_eopt()
Date: Mon, 03 Oct 2011 17:22:56 +0200
Message-ID: <4E89D350.10604@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:39570 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756436Ab1JCP0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:26:14 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by re04.intra2net.com (Postfix) with ESMTP id 037B43014E
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:14 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id BD14A2AC5A
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:13 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id C5AD42AC58
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:12 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 tc/em_cmp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/em_cmp.c b/tc/em_cmp.c
index 6addce0..3e6d00e 100644
--- a/tc/em_cmp.c
+++ b/tc/em_cmp.c
@@ -155,7 +155,7 @@ static int cmp_print_eopt(FILE *fd, struct tcf_ematch_hdr *hdr, void *data,
 		fprintf(fd, "u8 ");
 	else if (cmp->align == TCF_EM_ALIGN_U16)
 		fprintf(fd, "u16 ");
-	else if (cmp->align == TCF_EM_ALIGN_U16)
+	else if (cmp->align == TCF_EM_ALIGN_U32)
 		fprintf(fd, "u32 ");
 
 	fprintf(fd, "at %d layer %d ", cmp->off, cmp->layer);
-- 
1.7.4.4
