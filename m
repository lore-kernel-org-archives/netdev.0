From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] skge: Add DMA mask quirk for Marvell 88E8001 on
 ASUS P5NSLI motherboard.
Date: Mon, 08 Oct 2012 03:07:07 -0400 (EDT)
Message-ID: <20121008.030707.864754447318232909.davem@davemloft.net>
References: <5072760C.7060004@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: graham.gower@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472Ab2JHHHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 03:07:11 -0400
In-Reply-To: <5072760C.7060004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graham Gower <graham.gower@gmail.com>
Date: Mon, 08 Oct 2012 17:13:24 +1030

> Marvell 88E8001 on an ASUS P5NSLI motherboard is unable to
> send/receive
> packets on a system with >4gb ram unless a 32bit DMA mask is used.

Please format this ascii text properly.  WHy is there a line
with just two words surrounded by full nearly 80-column lines?

> +		.matches = {
> + DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),

THis is still formatted incorrectly, it's actually in the file
not due to your email client.

Can you indent the thing properly, please?

This is V4 of this patch, and suffering purely from first order coding
style and procedural stuff.  As you can imagine, it's very frustrating
to have to spend this much time getting such simple things taken care
of.
