From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for zd1201
Date: Tue, 29 Aug 2006 18:07:11 -0700
Message-ID: <20060830010711.GK8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:47296 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S932183AbWH3BHn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 21:07:43 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Jeroen Vreeken <pe1rxq@amsat.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi,

        WE-21 for ZyDAS driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/zd1201.20.c linux/drivers/net/wireless/zd1201.c
--- linux/drivers/net/wireless/zd1201.20.c	2006-08-28 18:00:18.000000000 -0700
+++ linux/drivers/net/wireless/zd1201.c	2006-08-28 18:00:01.000000000 -0700
@@ -1218,7 +1218,7 @@ static int zd1201_set_essid(struct net_d
 		return -EINVAL;
 	if (data->length < 1)
 		data->length = 1;
-	zd->essidlen = data->length-1;
+	zd->essidlen = data->length;
 	memset(zd->essid, 0, IW_ESSID_MAX_SIZE+1);
 	memcpy(zd->essid, essid, data->length);
 	return zd1201_join(zd, zd->essid, zd->essidlen);
