From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Tue, 11 Apr 2006 11:47:30 +1000
Message-ID: <1144720050.19353.26.camel@localhost.localdomain>
References: <20060410040120.GA4860@ens-lyon.fr>
	 <200604100607.33362.mb@bu3sch.de> <20060410042228.GN27596@ens-lyon.fr>
	 <200604100628.01483.mb@bu3sch.de> <20060410134625.GA25360@tuxdriver.com>
	 <20060410221359.GC27596@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932256AbWDKBrm@vger.kernel.org>
To: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
In-Reply-To: <20060410221359.GC27596@ens-lyon.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The hacks i see there is reallocating a buffer with GFP_DMA, so that
> means that if the ppc dma_alloc_coherent did the same thing as the i386
> counterpart (adding GFP_DMA if dma_mask is less than 32bits) it should
> work, no ?

Except that GFP_DMA covers the whole address space on ppc64...

Ben.
