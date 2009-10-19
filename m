From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix section mismatch in fec.c
Date: Sun, 18 Oct 2009 21:27:21 -0700 (PDT)
Message-ID: <20091018.212721.27805107.davem@davemloft.net>
References: <200910181525.48574.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sfking@fdwdc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37727
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750837AbZJSE06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 00:26:58 -0400
In-Reply-To: <200910181525.48574.sfking@fdwdc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven King <sfking@fdwdc.com>
Date: Sun, 18 Oct 2009 15:25:48 -0700

>    */
> -int __init fec_enet_init(struct net_device *dev, int index)
> +static int
> +fec_enet_init(struct net_device *dev, int index)
>  {

Don't change coding style when fixing a bug.

Fix this up and resubmit your fix, thanks.
