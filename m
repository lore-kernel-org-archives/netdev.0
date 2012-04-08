From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH] fixed coding style issue
Date: Sun, 8 Apr 2012 21:37:42 +0530
Message-ID: <20120408160742.GA4613@debian.Jeff>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Cc: ahiliation@yahoo.co.in
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm37-vm7.bullet.mail.bf1.yahoo.com ([72.30.238.207]:29482 "HELO
	nm37-vm7.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754817Ab2DHQLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2012 12:11:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

hello all,


i have worked on some coding style issues
on net/core/utils.c

please see attachment.

Thanks

/Jeffrin.

-- 
software engineer
Bohr Lab
department of computer science
Rajagiri school of engineering and technology.

--+HP7ph2BbKc20aGI
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0006-net-Fixed-coding-style-issues-relating-to-braces.patch"

>From fa37bfd6c2ef8ff81b38ad9dd4467a727d6def81 Mon Sep 17 00:00:00 2001
From: Jeffrin Jose <ahiliation@yahoo.co.in>
Date: Sun, 8 Apr 2012 00:09:11 +0530
Subject: [PATCH 6/6] net: Fixed coding style issues relating to braces.

Fixed coding style issues in net/core/utils.c
in relation with braces placement.
Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/core/utils.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/core/utils.c b/net/core/utils.c
index 386e263f..c2e8b41 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -59,14 +59,11 @@ __be32 in_aton(const char *str)
 	int i;
 
 	l = 0;
-	for (i = 0; i < 4; i++)
-	{
+	for (i = 0; i < 4; i++)	{
 		l <<= 8;
-		if (*str != '\0')
-		{
+		if (*str != '\0') {
 			val = 0;
-			while (*str != '\0' && *str != '.' && *str != '\n')
-			{
+			while (*str != '\0' && *str != '.' && *str != '\n') {
 				val *= 10;
 				val += *str - '0';
 				str++;
-- 
1.7.9


--+HP7ph2BbKc20aGI--
