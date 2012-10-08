From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] skge: Add DMA mask quirk for Marvell 88E8001 on
 ASUS P5NSLI motherboard.
Date: Mon, 08 Oct 2012 02:11:28 -0400 (EDT)
Message-ID: <20121008.021128.763232338754014461.davem@davemloft.net>
References: <507265B8.5070406@gmail.com>
	<20121008.013635.1877246075568372072.davem@davemloft.net>
	<50726AA4.7080901@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: graham.gower@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581Ab2JHGLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 02:11:31 -0400
In-Reply-To: <50726AA4.7080901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graham Gower <graham.gower@gmail.com>
Date: Mon, 08 Oct 2012 16:24:44 +1030

> Marvell 88E8001 on an ASUS P5NSLI motherboard is unable to
> send/receive
> packets on a system with >4gb ram unless a 32bit DMA mask is used.

This is still oddly formatted.

> +	{
> +		.ident = "ASUS P5NSLI",
> +		.matches = {
> + DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),

And this is even worse than before.
