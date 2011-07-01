From: Joe Perches <joe@perches.com>
Subject: Re: coding style question on indentation
Date: Fri, 01 Jul 2011 08:23:13 -0700
Message-ID: <1309533793.7277.51.camel@Joe-Laptop>
References: <3367B80B08154D42A3B2BC708B5D41F63F87EF145E@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3421 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752817Ab1GAPXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 11:23:14 -0400
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F63F87EF145E@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-07-01 at 04:20 -0700, Sathya.Perla@Emulex.Com wrote:
> a) Aligning the next line with the first argument by inserting a few spaces after the tabs - as in:
> 
> 	dma_unmap_page(&adapter->pdev->dev,
> 			   dma_unmap_addr(rx_page_info, bus),
> 			   adapter->big_page_size, DMA_FROM_DEVICE);

My preference as well, but your example may not be correct.

I think this better:

         1         2         3         4         5         6         7         8
12345678901234567890123456789012345678901234567890123456789012345678901234567890

	dma_unmap_page(&adapter->pdev->dev, dma_unmap_addr(rx_page_info, bus),
		       adapter->big_page_size, DMA_FROM_DEVICE);

maximally fill to 80 cols, then wrap with maximal tabs using spaces
if necessary to align args after opening parenthesis.
In this case, 2 tabs, 7 spaces.

It is your code though, do what you think best.


