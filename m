From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [2.6 patch] bonding/bond_main.c: fix cut'n'paste error
Date: Wed, 24 Oct 2007 15:51:08 -0700
Message-ID: <4858.1193266268@death>
References: <20071024162743.GV30533@stusta.de>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:52759 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760592AbXJXWvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 18:51:11 -0400
In-reply-to: <20071024162743.GV30533@stusta.de> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Adrian Bunk <bunk@kernel.org> wrote:
>This patch fixes a cut'n'paste error in
>commit 1b76b31693d4a6088dec104ff6a6ead54081a3c2.
>
>Signed-off-by: Adrian Bunk <bunk@kernel.org>

	Please apply.

	-J

Acked-by: Jay Vosburgh <fubar@us.ibm.com>


>---
>4888742f8d7fe3b97fbc2911aa46375048173d01 
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index e5fab4b..6937ef0 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3682,7 +3682,7 @@ static int bond_open(struct net_device *bond_dev)
> 	}
>
> 	if (bond->params.mode == BOND_MODE_8023AD) {
>-		INIT_DELAYED_WORK(&bond->ad_work, bond_alb_monitor);
>+		INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
> 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
> 		/* register to receive LACPDUs */
> 		bond_register_lacpdu(bond);
>
