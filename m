From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][NET] Alignment in mv643xx_eth
Date: Tue, 27 Feb 2007 04:21:56 -0500
Message-ID: <45E3F834.70307@garzik.org>
References: <20070226195206.GA10188@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47504 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965034AbXB0JZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:25:08 -0500
In-Reply-To: <20070226195206.GA10188@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> The driver contains this little piece of candy:
> 
> #if defined(CONFIG_DMA_NONCOHERENT) || defined(CONFIG_NOT_COHERENT_CACHE)
> #define ETH_DMA_ALIGN           L1_CACHE_BYTES
> #else
> #define ETH_DMA_ALIGN           8
> #endif
> 
> Any reason why we're not using dma_get_cache_alignment() instead?
> 
>   Ralf
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied


