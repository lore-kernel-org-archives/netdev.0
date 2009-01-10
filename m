From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 14/16] dma-debug: add checks for sync_single_sg_*
Date: Sun, 11 Jan 2009 00:46:41 +0100
Message-ID: <20090110234641.GB20843@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-15-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:59405 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752AbZAJXrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 18:47:10 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-15-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +void debug_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
> +			   int nelems, int direction)
> +{
> +	struct scatterlist *s;
> +	int i;
> +
> +	if (global_disable)
> +		return;

"if (unlikely(global_disable))" i suspect?

	Ingo
