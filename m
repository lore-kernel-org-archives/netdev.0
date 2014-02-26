From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] ieee802154: fix new function declaration
Date: Tue, 25 Feb 2014 22:38:29 -0700
Message-ID: <1393393109-11079-1-git-send-email-sakiwit@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:36077 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbaBZFlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 00:41:55 -0500
Received: by mail-pb0-f44.google.com with SMTP id rp16so495049pbb.31
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 21:41:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 8fad346f366a7 ("eee802154: add basic support for RF212 to
at86rf230 driver") introduced the new function is_rf212() with some
minor issues in declaration:

1) Fix the function type by changing it to bool as the function
   definition returns a boolean value. Additionally both callers of
   is_rf212() are expected to return a boolean value.

2) Fix the function specifier by deleting the inline keyword as the
   compiler takes care of that.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 34bf011584fb..dd9ef5e1c730 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -57,7 +57,7 @@ struct at86rf230_local {
 	int rssi_base_val;
 };
 
-static inline int is_rf212(struct at86rf230_local *local)
+static bool is_rf212(struct at86rf230_local *local)
 {
 	return local->part == 7;
 }
