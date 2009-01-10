From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 15/16] dma-debug: x86 architecture bindings
Date: Sun, 11 Jan 2009 00:04:54 +0100
Message-ID: <20090110230454.GI17917@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-16-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:47320 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755088AbZAJXFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 18:05:22 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-16-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> @@ -105,6 +109,7 @@ dma_unmap_single(struct device *dev, dma_addr_t addr, size_t size,
>  	struct dma_mapping_ops *ops = get_dma_ops(dev);
>  
>  	BUG_ON(!valid_dma_direction(direction));
> +	debug_unmap_single(dev, addr, size, direction);

It all looks very nice, i've got one small namespace structure request: 
could you please name all the callbacks in a consistent way, so that they 
mirror the method they instrument - with a "debug_" prefix?

I.e. the above one would be: debug_dma_unmap_single().

	Ingo
