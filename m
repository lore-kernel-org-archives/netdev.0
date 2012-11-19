From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 490/493] rfkill: remove use of __devexit
Date: Mon, 19 Nov 2012 13:27:19 -0500
Message-ID: <1353349642-3677-490-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41515 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340Ab2KSSfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:35:23 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Johannes Berg <johannes@sipsolutions.net> 
Cc: "John W. Linville" <linville@tuxdriver.com> 
Cc: "David S. Miller" <davem@davemloft.net> 
Cc: linux-wireless@vger.kernel.org 
Cc: netdev@vger.kernel.org 
---
 net/rfkill/rfkill-regulator.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rfkill/rfkill-regulator.c b/net/rfkill/rfkill-regulator.c
index c864e44..4b5ab21 100644
--- a/net/rfkill/rfkill-regulator.c
+++ b/net/rfkill/rfkill-regulator.c
@@ -122,7 +122,7 @@ out:
 	return ret;
 }
 
-static int __devexit rfkill_regulator_remove(struct platform_device *pdev)
+static int rfkill_regulator_remove(struct platform_device *pdev)
 {
 	struct rfkill_regulator_data *rfkill_data = platform_get_drvdata(pdev);
 	struct rfkill *rf_kill = rfkill_data->rf_kill;
-- 
1.8.0
