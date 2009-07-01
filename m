From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Support DMA-API debugging facility on PowerPC
Date: Wed, 1 Jul 2009 10:00:18 -0400
Message-ID: <20090701140018.GA14265@infradead.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227286492.4901.208.camel@macbook.infradead.org> <20081121165722.GD1386@amd.com> <1227287215.4901.213.camel@macbook.infradead.org> <20081121171802.GK733@elte.hu> <20081121172046.GF1386@amd.com> <1227288269.4901.222.camel@macbook.infradead.org> <20081121172722.GG1386@amd.com> <1233873842.8135.6.camel@macbook.infradead.org> <1246454380.3681.1634.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, benh@kernel.crashing.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org, Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39183 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561AbZGAOAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 10:00:18 -0400
Content-Disposition: inline
In-Reply-To: <1246454380.3681.1634.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 02:19:40PM +0100, David Woodhouse wrote:
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> Tested-by: Johannes Berg <johannes@sipsolutions.net>
> ---
> Some fixing from Johannes to make it apply to a current kernel...

Looks fine for .31, but for the next release powerpc should probably
switch to using <asm-generic/dma-mapping-common.h> and get it for
free.

