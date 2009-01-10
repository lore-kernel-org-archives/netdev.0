From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 15/16] dma-debug: x86 architecture bindings
Date: Sun, 11 Jan 2009 00:48:18 +0100
Message-ID: <20090110234818.GC20843@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-16-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:46617 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752AbZAJXsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 18:48:41 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-16-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> @@ -175,6 +189,8 @@ dma_sync_single_range_for_device(struct device *hwdev, dma_addr_t dma_handle,
>  	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
>  
>  	BUG_ON(!valid_dma_direction(direction));
> +        debug_sync_single_range_for_device(hwdev, dma_handle, offset,

whitespace damage here.

	Ingo
