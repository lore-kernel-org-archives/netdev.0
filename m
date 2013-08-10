From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] skge: add dma_mapping check
Date: Sat, 10 Aug 2013 13:29:35 -0700 (PDT)
Message-ID: <20130810.132935.1257046025460198490.davem@davemloft.net>
References: <20130804.183553.514470399074672614.davem@davemloft.net>
	<52062955.90102@gmail.com>
	<20130810104100.0ae20aa6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pomidorabelisima@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758808Ab3HJU3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 16:29:36 -0400
In-Reply-To: <20130810104100.0ae20aa6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 10 Aug 2013 10:41:00 -0700

> The DMA debug check insists that the call to sync_single has
> to be the same length as the mapping. The driver is only bothering
> to sync the bytes that matter (got received) rather than the whole
> map.
> 
> In reality that is not required, but I will make a patch anyway.

PCI and other system controllers will prefetch, I think it can matter.
