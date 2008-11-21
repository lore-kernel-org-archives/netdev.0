From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 02/10] x86: add data structures for DMA-API debugging
Date: Fri, 21 Nov 2008 17:42:54 +0100
Message-ID: <20081121164254.GC733@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-3-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:53522 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757417AbYKUQnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 11:43:15 -0500
Content-Disposition: inline
In-Reply-To: <1227284770-19215-3-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +#ifndef __ASM_X86_DMA_DEBUG
> +#define __ASM_X86_DMA_DEBUG
> +
> +/* Allocation flags */
> +#define DMA_DEBUG_SINGLE        0
> +#define DMA_DEBUG_SG            1
> +#define DMA_DEBUG_COHERENT      2

please use enum for such internal flags, not define.

> +
> +struct device;
> +struct list_head;
> +
> +struct dma_debug_entry {
> +	struct list_head list;
> +	struct device *dev;
> +	int type;
> +	void *cpu_addr;
> +	u64 dev_addr;
> +	u64 size;
> +	int direction;
> +};

please align new x86/include structures vertically like this:

> +struct dma_debug_entry {
> +	struct list_head	list;
> +	struct device		*dev;
> +	int			type;
> +	void			*cpu_addr;
> +	u64			dev_addr;
> +	u64			size;
> +	int			direction;
> +};

[ for the arts major students reading lkml ;-) ]

	Ingo
