From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH 04/10] ss: prepare timer for output handler usage
Date: Mon, 10 Aug 2015 01:13:20 +0200
Message-ID: <1439162006-11421-5-git-send-email-matthias.tafelmeier@gmx.net>
References: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:55889 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980AbbHIXNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2015 19:13:36 -0400
In-Reply-To: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
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
index e241b2f..1b3ef90 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -647,7 +647,7 @@ static const char *sstate_namel[] = {
 	[SS_CLOSING] = "closing",
 };
 
-static const char *tmr_name[] = {
+const char *ss_timer_name[] = {
 	"off",
 	"on",
 	"keepalive",
-- 
1.9.1
