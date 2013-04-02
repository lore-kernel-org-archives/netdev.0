From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] ISDN:divert: beautify code: useless 'break', 'return (0)',
 additional comments.
Date: Tue, 02 Apr 2013 09:37:56 +0800
Message-ID: <515A3674.7090606@asianux.com>
References: <5158E854.7060902@asianux.com> <515993E1.5010508@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	isdn@linux-pingi.de, Jiri Slaby <jslaby@suse.cz>,
	'Jiri Kosina' <trivial@kernel.org>, tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:41399 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759704Ab3DBBi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 21:38:28 -0400
In-Reply-To: <515993E1.5010508@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  delete useless 'break' after 'return'.
  let 'return 0' instead of 'return (0)'
  also give a comment for 'break' to let readers notice it.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
 drivers/isdn/divert/isdn_divert.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/divert/isdn_divert.c b/drivers/isdn/divert/isdn_divert.c
index db432e6..50749a7 100644
--- a/drivers/isdn/divert/isdn_divert.c
+++ b/drivers/isdn/divert/isdn_divert.c
@@ -441,8 +441,7 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 
 		switch (dv->rule.action) {
 		case DEFLECT_IGNORE:
-			return (0);
-			break;
+			return 0;
 
 		case DEFLECT_ALERT:
 		case DEFLECT_PROCEED:
@@ -510,10 +509,9 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 			break;
 
 		default:
-			return (0); /* ignore call */
-			break;
+			return 0; /* ignore call */
 		} /* switch action */
-		break;
+		break; /* will break the 'for' looping */
 	} /* scan_table */
 
 	if (cs) {
-- 
1.7.7.6
