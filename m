From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v3 04/10] ss: prepare timer for output handler usage
Date: Thu, 20 Aug 2015 22:40:15 +0200
Message-ID: <1440103221-21854-5-git-send-email-matthias.tafelmeier@gmx.net>
References: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:58451 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868AbbHTUkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 16:40:53 -0400
In-Reply-To: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor preparation Patch

Renamed, and exported timer to not have to pass it as a function local
parameter argument.

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 4cc6991..e7ea041 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -649,7 +649,7 @@ static const char *sstate_namel[] = {
 	[SS_CLOSING] = "closing",
 };
 
-static const char *tmr_name[] = {
+const char *ss_timer_name[] = {
 	"off",
 	"on",
 	"keepalive",
-- 
1.9.1
