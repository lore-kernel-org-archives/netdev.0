From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 08/16] dma-debug: add core checking functions
Date: Sun, 11 Jan 2009 00:13:41 +0100
Message-ID: <20090110231341.GM17917@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-9-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:37743 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754159AbZAJXOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 18:14:06 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-9-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +static char *type2name[3] = { "single", "scather-gather", "coherent" };
> +
> +static char *dir2name[4] = { "DMA_BIDIRECTIONAL", "DMA_TO_DEVICE",
> +			     "DMA_FROM_DEVICE", "DMA_NONE" };

Should be const i guess.

	Ingo
