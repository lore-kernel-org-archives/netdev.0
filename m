From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [patch] qlge: fix an "&&" vs "||" bug
Date: Thu, 12 Jul 2012 11:15:56 -0700
Message-ID: <5E4F49720D0BAD499EE1F01232234BA8774378FA29@AVEXMB1.qlogic.org>
References: <20120712144702.GB24202@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ron Mercer <ron.mercer@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe006.messaging.microsoft.com ([216.32.180.189]:5711
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932690Ab2GLSQJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 14:16:09 -0400
In-Reply-To: <20120712144702.GB24202@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original Message-----
>From: Dan Carpenter [mailto:dan.carpenter@oracle.com] 
>Sent: Thursday, July 12, 2012 7:47 AM
>To: Anirban Chakraborty
>Cc: Jitendra Kalsaria; Ron Mercer; Dept-Eng Linux Driver; netdev; kernel-janitors@vger.kernel.org
>Subject: [patch] qlge: fix an "&&" vs "||" bug
>
>The condition is always true so WOL will never work.
>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
>diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
>index 3d4462b..6f316ab 100644
>--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
>+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
>@@ -440,7 +440,7 @@ static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
> 	unsigned short ssys_dev = qdev->pdev->subsystem_device;
> 
> 	/* WOL is only supported for mezz card. */
>-	if (ssys_dev != QLGE_MEZZ_SSYS_ID_068 ||
>+	if (ssys_dev != QLGE_MEZZ_SSYS_ID_068 &&
> 			ssys_dev != QLGE_MEZZ_SSYS_ID_180) {
> 		netif_info(qdev, drv, qdev->ndev,
> 				"WOL is only supported for mezz card\n");

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
