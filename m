From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 06/10] x86: add check code for map/unmap_sg code
Date: Fri, 21 Nov 2008 18:10:55 +0100
Message-ID: <20081121171055.GJ733@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-7-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:59191 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754318AbYKURLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 12:11:17 -0500
Content-Disposition: inline
In-Reply-To: <1227284770-19215-7-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +	ret =  ops->map_sg(hwdev, sg, nents, direction);

stray double space in '=  ops'.

another very small detail:

> +	unsigned long flags;
> +	struct dma_debug_entry *entry;
> +	struct scatterlist *s;
> +	int i;

please order them like this, similar to the include line:

> +	struct dma_debug_entry *entry;
> +	struct scatterlist *s;
> +	unsigned long flags;
> +	int i;

that makes the whole variable section non-intrusive. (and also acts as 
a patch-conflict-reducer mechanism in the future - when variable 
definition lines get particularly long)

(not a hard rule, exceptions are possible - grouping same-type fields 
together, etc.)

	Ingo
