From: Fabien Siron <fabien.siron@epita.fr>
Subject: [PATCH iproute2] misc/ss: Add family list to -f option in _usage()
Date: Mon, 6 Jun 2016 14:53:38 +0000
Message-ID: <20160606145338.9587-1-fabien.siron@epita.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Fabien Siron <fabien.siron@epita.fr>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0076.outbound.protection.outlook.com ([157.56.112.76]:40054
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750878AbcFFQZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 12:25:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabien Siron <fabien.siron@epita.fr>
---
 misc/ss.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/misc/ss.c b/misc/ss.c
index 23fff19..9c456d4 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3581,6 +3581,7 @@ static void _usage(FILE *dest)
 "   -w, --raw           display only RAW sockets\n"
 "   -x, --unix          display only Unix domain sockets\n"
 "   -f, --family=FAMILY display sockets of type FAMILY\n"
+"       FAMILY := {inet|inet6|link|unix|netlink|help}\n"
 "\n"
 "   -K, --kill          forcibly close sockets, display what was closed\n"
 "\n"
-- 
2.8.3
