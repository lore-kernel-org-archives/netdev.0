From: Manoil Claudiu <claudiu.manoil@freescale.com>
Subject: RE: [PATCH] freescale:Make the function gfar_clean_tx_ring static
Date: Wed, 8 Jul 2015 07:40:28 +0000
Message-ID: <DM2PR03MB41469B75835295813DD174D9C910@DM2PR03MB414.namprd03.prod.outlook.com>
References: <1436299280-25565-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0131.outbound.protection.outlook.com ([207.46.100.131]:21671
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934501AbbGHIN6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 04:13:58 -0400
In-Reply-To: <1436299280-25565-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Nicholas Krause [mailto:xerofoify@gmail.com]
> Sent: Tuesday, July 07, 2015 11:01 PM
> To: davem@davemloft.net
> Cc: Manoil Claudiu-B08782; haokexin@gmail.com;
> matei.pavaluca@freescale.com; u.kleine-koenig@pengutronix.de;
> jingchang.lu@freescale.com; tobias@waldekranz.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH] freescale:Make the function gfar_clean_tx_ring static
> 

Thanks, but for the sake of consistency (and for easy git tracking)
patches for this eth driver start with "gianfar: [...]" in the subject.
I don't see the urgency of turning all the driver functions to static.
There is some value to having some key functions defined as global,
like for debugging reasons, it helps with profiling, etc.

Claudiu
