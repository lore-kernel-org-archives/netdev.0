From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 00/10] sfc changes for 2.6.37
Date: Fri, 10 Sep 2010 20:59:50 +0100
Message-ID: <1284148790.2267.322.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
	 <20100910.122854.184831961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51482 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab0IJT7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 15:59:54 -0400
In-Reply-To: <20100910.122854.184831961.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-09-10 at 12:28 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 10 Sep 2010 17:40:17 +0100
> 
> > One new feature - variable ring sizes - and a few bug fixes.
> > 
> > Ben.
> > 
> > Ben Hutchings (9):
> >   sfc: Use MCDI RX_BAD_FCS_PKTS count as MAC rx_bad count
> >   sfc: Accumulate RX_NODESC_DROP count in rx_dropped, not
> >     rx_over_errors
> >   sfc: Remove declarations of functions that no longer exist
> >   sfc: Fix failure paths in efx_probe_port()
> >   sfc: Allocate DMA and event rings using GFP_KERNEL
> >   sfc: Abstract channel and index lookup for RX queues
> >   sfc: Refactor channel and queue lookup and iteration
> >   sfc: Allocate each channel separately, along with its RX and TX
> >     queues
> >   sfc: Allow changing the DMA ring sizes dynamically via ethtool
> > 
> > Steve Hodgson (1):
> >   sfc: Make the dmaq size a run-time setting (rather than compile-time)
> 
> All applied, thanks Ben.
> 
> It could be argued that rx_over_errors is meant to count internal chip
> FIFO overflows during receive, which occur when DMA cannot meet demand
> for long periods of time.  Indicating that FIFO settings need to be
> increased or PCI settings adjusted.
> 
> Anyways, just my view.

It would really be nice to have more verbose definitions of these in
rtnetlink.h.  The decider for us was that ifconfig includes
rx_over_errors in RX frame errors i.e. bad packets.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

