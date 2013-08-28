From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: question about drivers/net/ethernet/mellanox/mlx4/en_tx.c
Date: Wed, 28 Aug 2013 14:48:12 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308281447500.2279@hadrien>
References: <alpine.DEB.2.02.1308271904520.2282@hadrien> <521DF064.7090100@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:1199 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753741Ab3H1Msh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 08:48:37 -0400
In-Reply-To: <521DF064.7090100@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Aug 2013, Amir Vadai wrote:

> On 27/08/2013 20:07, Julia Lawall wrote:
> > Hello,
> >
> > I was wondering why in drivers/net/ethernet/mellanox/mlx4/en_tx.c there
> > are a number of uses of dma_sync_single_for_cpu without corresponding uses
> > of dma_sync_single_for_device (for example in mlx4_en_rx_skb)?  In most
> > drivers they come together.
> >
> > thanks,
> > julia
> >
>
> Hi Julia,
>
> I guess you meant to en_rx.c and not en_tx.c

Oops, yes.

> It looks like a bug.
> The whole skb buffers allocation and mapping is expected to be
> overhauled soon - and this will be fixed as part of it.

OK, thanks for the explanation.

julia
