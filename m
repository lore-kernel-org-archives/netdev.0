From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] skge: Add DMA mask quirk for Marvell 88E8001 on
 ASUS P5NSLI motherboard
Date: Mon, 08 Oct 2012 14:49:19 -0400 (EDT)
Message-ID: <20121008.144919.2143699900297423013.davem@davemloft.net>
References: <1349715275-12730-1-git-send-email-jan.ceuleers@computer.org>
	<1349721290-16374-1-git-send-email-jan.ceuleers@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, graham.gower@gmail.com,
	shemminger@vyatta.com
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642Ab2JHStW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 14:49:22 -0400
In-Reply-To: <1349721290-16374-1-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Mon,  8 Oct 2012 20:34:50 +0200

> From: Graham Gower <graham.gower@gmail.com>
> 
> Marvell 88E8001 on an ASUS P5NSLI motherboard is unable to send/receive
> packets on a system with >4gb ram unless a 32bit DMA mask is used.
> 
> This issue has been around for years and a fix was sent 3.5 years ago, but
> there was some debate as to whether it should instead be fixed as a PCI quirk.
> http://www.spinics.net/lists/netdev/msg88670.html
> 
> However, 18 months later a similar workaround was introduced for another
> chipset exhibiting the same problem.
> http://www.spinics.net/lists/netdev/msg142287.html
> 
> Signed-off-by: Graham Gower <graham.gower@gmail.com>
> Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied and queued up for -stable.
