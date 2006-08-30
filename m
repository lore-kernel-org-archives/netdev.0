From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for wl3501
Date: Tue, 29 Aug 2006 18:05:37 -0700
Message-ID: <20060830010537.GJ8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:62463 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S932137AbWH3BGI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 21:06:08 -0400
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi,

        WE-21 for wl3501 driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

--- linux/drivers/net/wireless/wl3501_cs.20.c	2006-08-28 17:41:19.000000000 -0700
+++ linux/drivers/net/wireless/wl3501_cs.c	2006-08-28 17:41:28.000000000 -0700
@@ -1802,15 +1802,15 @@ static int wl3501_get_retry(struct net_d
 				      &retry, sizeof(retry));
 	if (rc)
 		goto out;
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		goto set_value;
 	}
 	rc = wl3501_get_mib_value(this, WL3501_MIB_ATTR_SHORT_RETRY_LIMIT,
 				  &retry, sizeof(retry));
 	if (rc)
 		goto out;
-	wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MIN;
+	wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_SHORT;
 set_value:
 	wrqu->retry.value = retry;
 	wrqu->retry.disabled = 0;
