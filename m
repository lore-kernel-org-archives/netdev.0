From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 351/493] atm: remove use of __devinitconst
Date: Mon, 19 Nov 2012 13:25:00 -0500
Message-ID: <1353349642-3677-351-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41486 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210Ab2KSSek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:34:40 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinitconst is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil> 
Cc: linux-atm-general@lists.sourceforge.net 
Cc: netdev@vger.kernel.org 
---
 drivers/atm/eni.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 34416f6..1f1aa57 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1567,7 +1567,7 @@ tx_complete++;
 /*--------------------------------- entries ---------------------------------*/
 
 
-static char * const media_name[] __devinitconst = {
+static char * const media_name[] = {
     "MMF", "SMF", "MMF", "03?", /*  0- 3 */
     "UTP", "05?", "06?", "07?", /*  4- 7 */
     "TAXI","09?", "10?", "11?", /*  8-11 */
-- 
1.8.0
