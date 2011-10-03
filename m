From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 06/11] Add missing closedir() call in do_show()
Date: Mon, 03 Oct 2011 17:23:42 +0200
Message-ID: <4E89D37E.5020907@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:39573 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756502Ab1JCP0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:26:17 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by re04.intra2net.com (Postfix) with ESMTP id 588A5300D2
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:16 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id 2C32A2AC58
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:16 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id 441492AC59
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:14 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 ip/iptuntap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 588926c..29f2777 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -298,6 +298,7 @@ static int do_show(int argc, char **argv)
 			printf(" group %ld", group);
 		printf("\n");
 	}
+	closedir(dir);
 	return 0;
 }
 
-- 
1.7.4.4
