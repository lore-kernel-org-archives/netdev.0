From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/can/mscan: add __iomem annotations
Date: Wed, 17 Aug 2011 20:16:48 -0700 (PDT)
Message-ID: <20110817.201648.2216828961982296766.davem@davemloft.net>
References: <1313405834-10340-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, w.sang@pengutronix.de,
	socketcan-core@lists.berlios.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805Ab1HRDSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 23:18:00 -0400
In-Reply-To: <1313405834-10340-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 15 Aug 2011 12:57:14 +0200

> This patch fixes the following sparse warning by adding the missing
> __iomem annotation.
> 
> drivers/net/can/mscan/mscan.c:73:32: warning: incorrect type in argument 1 (different address spaces)
> drivers/net/can/mscan/mscan.c:73:32:    expected unsigned char volatile [noderef] [usertype] <asn:2>*addr
> drivers/net/can/mscan/mscan.c:73:32:    got unsigned char *<noident>
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
> 
> This patch applies so current net-next-2.6/master and can be pulled:
> 
> The following changes since commit b333293058aa2d401737c7246bce58f8ba00906d:
> 
>   qeth: add support for af_iucv HiperSockets transport (2011-08-13 01:10:17 -0700)
> 
> are available in the git repository at:
>   git://git.pengutronix.de/git/mkl/linux-2.6.git can/mscan

Pulled, thanks.
