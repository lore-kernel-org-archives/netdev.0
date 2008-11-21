From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 07/10] x86: add checks for alloc/free_coherent code
Date: Fri, 21 Nov 2008 17:57:30 +0100
Message-ID: <20081121165730.GE733@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-8-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:48017 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756382AbYKUQ5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 11:57:52 -0500
Content-Disposition: inline
In-Reply-To: <1227284770-19215-8-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


please use this nice and clean structure init style:

> +	entry->type      = DMA_DEBUG_COHERENT;
> +	entry->dev       = dev;
> +	entry->cpu_addr  = virt;
> +	entry->size      = size;
> +	entry->dev_addr  = dma_addr;
> +	entry->direction = DMA_BIDIRECTIONAL;

here too:

> +	struct dma_debug_entry ref = {
> +		.type = DMA_DEBUG_COHERENT,
> +		.dev = dev,
> +		.cpu_addr = virt,
> +		.dev_addr = addr,
> +		.size = size,
> +		.direction = DMA_BIDIRECTIONAL,
> +	};

	Ingo
