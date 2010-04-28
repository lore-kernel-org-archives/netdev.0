From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 7/7] Bugfix: Link selection was swapped in switch.
Date: Wed, 28 Apr 2010 20:54:40 +0200
Message-ID: <1272480880-30672-7-git-send-email-sjur.brandeland@stericsson.com>
References: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-3-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-4-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-5-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-6-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	sjurbr@gmail.com, linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:35420 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756573Ab0D1Szd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:55:33 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00K4MOKEDG80@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:26 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00MYUOK4Q560@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:26 +0200 (CEST)
In-reply-to: <1272480880-30672-6-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 0145bae..024fd5b 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -247,10 +247,10 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 
 		switch (caifdev->link_select) {
 		case CAIF_LINK_HIGH_BANDW:
-			pref = CFPHYPREF_LOW_LAT;
+			pref = CFPHYPREF_HIGH_BW;
 			break;
 		case CAIF_LINK_LOW_LATENCY:
-			pref = CFPHYPREF_HIGH_BW;
+			pref = CFPHYPREF_LOW_LAT;
 			break;
 		default:
 			pref = CFPHYPREF_HIGH_BW;
-- 
1.6.3.3

