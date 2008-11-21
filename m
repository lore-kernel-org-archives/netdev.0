From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 10/10] x86: add checks for sync_sg* code
Date: Fri, 21 Nov 2008 17:59:48 +0100
Message-ID: <20081121165948.GG733@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-11-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:52583 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062AbYKURAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 12:00:11 -0500
Content-Disposition: inline
In-Reply-To: <1227284770-19215-11-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +	for_each_sg(sg, s, nelems, i)
> +		check_sync(dev, s->dma_address, s->dma_length, 0,
> +			   direction, true);

curly braces needed for the multi-line loop body.

> +	for_each_sg(sg, s, nelems, i)
> +		check_sync(dev, s->dma_address, s->dma_length, 0,
> +			   direction, false);

ditto.

	Ingo
