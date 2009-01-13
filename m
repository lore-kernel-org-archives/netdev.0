From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03/16] dma-debug: add hash functions for
 dma_debug_entries
Date: Tue, 13 Jan 2009 00:51:18 -0800
Message-ID: <20090113005118.82f5037b.akpm@linux-foundation.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
	<1231517970-20288-4-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49165 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755754AbZAMIxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 03:53:04 -0500
In-Reply-To: <1231517970-20288-4-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Jan 2009 17:19:17 +0100 Joerg Roedel <joerg.roedel@amd.com> wrote:

> +struct hash_bucket {
> +	struct list_head list;
> +	spinlock_t lock;
> +} ____cacheline_aligned;

__cacheline_aligned_in_smp.

This all looks like an exotically large amount of code for a debug thingy?
