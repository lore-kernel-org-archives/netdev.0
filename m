From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: coding style question on indentation
Date: Tue, 05 Jul 2011 13:54:52 -0600
Message-ID: <4E136C0C.8010806@genband.com>
References: <3367B80B08154D42A3B2BC708B5D41F63F87EF145E@EXMAIL.ad.emulex.com> <1309533793.7277.51.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sathya.Perla@Emulex.Com, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og112.obsmtp.com ([64.18.2.177]:47590 "EHLO
	exprod7og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624Ab1GETzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 15:55:02 -0400
In-Reply-To: <1309533793.7277.51.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2011 09:23 AM, Joe Perches wrote:

> I think this better:
>
>           1         2         3         4         5         6         7         8
> 12345678901234567890123456789012345678901234567890123456789012345678901234567890
>
> 	dma_unmap_page(&adapter->pdev->dev, dma_unmap_addr(rx_page_info, bus),
> 		       adapter->big_page_size, DMA_FROM_DEVICE);
>
> maximally fill to 80 cols, then wrap with maximal tabs using spaces
> if necessary to align args after opening parenthesis.
> In this case, 2 tabs, 7 spaces.

I think the most flexible is to use hard tabs to align the continued 
line to the same level of indentation as the parent line, then use 
spaces for "pretty" alignment.  That way, it all lines up regardless of 
how many spaces the viewer has set for the equivalent size of hard tabs.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
