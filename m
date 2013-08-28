From: Amir Vadai <amirv@mellanox.com>
Subject: Re: question about drivers/net/ethernet/mellanox/mlx4/en_tx.c
Date: Wed, 28 Aug 2013 15:43:16 +0300
Message-ID: <521DF064.7090100@mellanox.com>
References: <alpine.DEB.2.02.1308271904520.2282@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:43987 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755416Ab3H1MnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 08:43:21 -0400
In-Reply-To: <alpine.DEB.2.02.1308271904520.2282@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/08/2013 20:07, Julia Lawall wrote:
> Hello,
> 
> I was wondering why in drivers/net/ethernet/mellanox/mlx4/en_tx.c there
> are a number of uses of dma_sync_single_for_cpu without corresponding uses
> of dma_sync_single_for_device (for example in mlx4_en_rx_skb)?  In most
> drivers they come together.
> 
> thanks,
> julia
> 

Hi Julia,

I guess you meant to en_rx.c and not en_tx.c

It looks like a bug.
The whole skb buffers allocation and mapping is expected to be
overhauled soon - and this will be fixed as part of it.

Thanks,
Amir
