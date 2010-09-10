From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 00/10] sfc changes for 2.6.37
Date: Fri, 10 Sep 2010 12:28:54 -0700 (PDT)
Message-ID: <20100910.122854.184831961.davem@davemloft.net>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50568
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752737Ab0IJT2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 15:28:37 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 10 Sep 2010 17:40:17 +0100

> One new feature - variable ring sizes - and a few bug fixes.
> 
> Ben.
> 
> Ben Hutchings (9):
>   sfc: Use MCDI RX_BAD_FCS_PKTS count as MAC rx_bad count
>   sfc: Accumulate RX_NODESC_DROP count in rx_dropped, not
>     rx_over_errors
>   sfc: Remove declarations of functions that no longer exist
>   sfc: Fix failure paths in efx_probe_port()
>   sfc: Allocate DMA and event rings using GFP_KERNEL
>   sfc: Abstract channel and index lookup for RX queues
>   sfc: Refactor channel and queue lookup and iteration
>   sfc: Allocate each channel separately, along with its RX and TX
>     queues
>   sfc: Allow changing the DMA ring sizes dynamically via ethtool
> 
> Steve Hodgson (1):
>   sfc: Make the dmaq size a run-time setting (rather than compile-time)

All applied, thanks Ben.

It could be argued that rx_over_errors is meant to count internal chip
FIFO overflows during receive, which occur when DMA cannot meet demand
for long periods of time.  Indicating that FIFO settings need to be
increased or PCI settings adjusted.

Anyways, just my view.
