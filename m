From: Kamil Rytarowski <n54@gmx.com>
Subject: iproute2 patch against GCC 4.8.0
Date: Fri, 03 May 2013 18:52:21 +0200
Message-ID: <5183EB45.8040504@gmx.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000508000909030607040705"
To: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:63221 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753486Ab3ECQtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 12:49:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000508000909030607040705
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello!

I'm attaching a patch [1] "Feed GCC 4.8.0 against new warning that is 
shipped with -Wall: -Wsizeof-pointer-memaccess.".

More details: http://gcc.gnu.org/gcc-4.8/porting_to.html

Regards,

[1] 0001-Feed-GCC-4.8.0-against-new-warning-that-is-shipped-w.patch

--------------000508000909030607040705
Content-Type: text/x-patch;
 name="0001-Feed-GCC-4.8.0-against-new-warning-that-is-shipped-w.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-Feed-GCC-4.8.0-against-new-warning-that-is-shipped-w.pa";
 filename*1="tch"

>From 1f3ea01fe2ff61cbbca6474f7d9903a0756a4f44 Mon Sep 17 00:00:00 2001
From: Kamil Rytarowski <n54@gmx.com>
Date: Fri, 3 May 2013 18:43:38 +0200
Subject: [PATCH] Feed GCC 4.8.0 against new warning that is shipped with
 -Wall: -Wsizeof-pointer-memaccess.

---
 misc/lnstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/lnstat.c b/misc/lnstat.c
index bd19cc1..90198b7 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -166,7 +166,7 @@ static struct table_hdr *build_hdr_string(struct lnstat_file *lnstat_files,
 
 	for (i = 0; i < HDR_LINES; i++) {
 		th.hdr[i] = malloc(HDR_LINE_LENGTH);
-		memset(th.hdr[i], 0, sizeof(th.hdr[i]));
+		memset(th.hdr[i], 0, HDR_LINE_LENGTH);
 	}
 
 	for (i = 0; i < fps->num; i++) {
-- 
1.8.1.5


--------------000508000909030607040705--
