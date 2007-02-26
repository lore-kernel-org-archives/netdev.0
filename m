From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [RFC][NET] Alignment in mv643xx_eth
Date: Mon, 26 Feb 2007 14:48:46 -0700
Message-ID: <20070226214846.GA18375@xyzzy.farnsworth.org>
References: <20070226195206.GA10188@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, Jeff Garzik <jeff@garzik.org>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:3216 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932503AbXBZVss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 16:48:48 -0500
Content-Disposition: inline
In-Reply-To: <20070226195206.GA10188@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 26, 2007 at 07:52:06PM +0000, Ralf Baechle wrote:
> The driver contains this little piece of candy:
> 
> #if defined(CONFIG_DMA_NONCOHERENT) || defined(CONFIG_NOT_COHERENT_CACHE)
> #define ETH_DMA_ALIGN           L1_CACHE_BYTES
> #else
> #define ETH_DMA_ALIGN           8
> #endif
> 
> Any reason why we're not using dma_get_cache_alignment() instead?

Not that I can think of.

ACK.

Dale Farnsworth
