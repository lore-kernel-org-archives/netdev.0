From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 06/10] x86: add check code for map/unmap_sg code
Date: Fri, 21 Nov 2008 17:58:09 +0100
Message-ID: <20081121165809.GF733@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-7-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:52108 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756517AbYKUQ6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 11:58:32 -0500
Content-Disposition: inline
In-Reply-To: <1227284770-19215-7-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


please use this nice structure init style:

> +		entry->type      = DMA_DEBUG_SG;
> +		entry->dev       = dev;
> +		entry->cpu_addr  = sg_virt(s);
> +		entry->size      = s->length;
> +		entry->dev_addr  = s->dma_address;
> +		entry->direction = direction;

here too:

> +		struct dma_debug_entry ref = {
> +			.type = DMA_DEBUG_SG,
> +			.dev = dev,
> +			.cpu_addr = sg_virt(s),
> +			.dev_addr = s->dma_address,
> +			.size = s->length,
> +			.direction = dir,

	Ingo
