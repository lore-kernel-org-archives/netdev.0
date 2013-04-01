From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] drivers/isdn/divert: beautify code, delete useless 'break'
Date: Mon, 01 Apr 2013 09:52:20 +0800
Message-ID: <5158E854.7060902@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>
To: isdn@linux-pingi.de, Jiri Slaby <jslaby@suse.cz>,
	'Jiri Kosina' <trivial@kernel.org>, tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:6480 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589Ab3DABwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 21:52:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  delete useless break statements.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/isdn/divert/isdn_divert.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/divert/isdn_divert.c b/drivers/isdn/divert/isdn_divert.c
index db432e6..76d505e 100644
--- a/drivers/isdn/divert/isdn_divert.c
+++ b/drivers/isdn/divert/isdn_divert.c
@@ -442,7 +442,6 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 		switch (dv->rule.action) {
 		case DEFLECT_IGNORE:
 			return (0);
-			break;
 
 		case DEFLECT_ALERT:
 		case DEFLECT_PROCEED:
@@ -511,7 +510,6 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 
 		default:
 			return (0); /* ignore call */
-			break;
 		} /* switch action */
 		break;
 	} /* scan_table */
-- 
1.7.7.6
