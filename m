From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: coding style question on indentation
Date: Fri, 01 Jul 2011 12:52:38 +0100
Message-ID: <1309521158.3093.1670.camel@localhost>
References: <3367B80B08154D42A3B2BC708B5D41F63F87EF145E@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50960 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516Ab1GALwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 07:52:41 -0400
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F63F87EF145E@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-07-01 at 04:20 -0700, Sathya.Perla@Emulex.Com wrote:
> Hi,
> Which of the following styling is preferable when a function
> invocation spans more than one line:
> 
> a) Aligning the next line with the first argument by inserting a few
> spaces after the tabs - as in:
> 
> 	dma_unmap_page(&adapter->pdev->dev,
> 			   dma_unmap_addr(rx_page_info, bus),
> 			   adapter->big_page_size, DMA_FROM_DEVICE);

My preference, for what it's worth.

> Documentation/CodingStyle says "spaces are never used for indentation", but I see
> scripts/Lindent inserting spaces after tabs for alignment.

I think that's meant to apply to indentation at the start of a statement
or declaration, not when wrapping.

> OR
> 
> b) Just using tabs without needing to align as above:
> 
> 	dma_unmap_page(&adapter->pdev->dev,
> 			dma_unmap_addr(rx_page_info, bus),
> 			adapter->big_page_size, DMA_FROM_DEVICE);

Popular but ugly in my opinion.

Some people also use a single extra tab to indent after wrapping,
whether or not the line break is within a parenthesised expression or
argument list.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

