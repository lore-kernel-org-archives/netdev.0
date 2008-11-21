From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Fri, 21 Nov 2008 16:54:52 +0000
Message-ID: <1227286492.4901.208.camel@macbook.infradead.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42651 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbYKUQzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:55:01 -0500
In-Reply-To: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-21 at 17:26 +0100, Joerg Roedel wrote:
> this patchset introduces code to debug drivers usage of the DMA-API.
> Tests with hardware IOMMUs have shown several bugs in drivers
> regarding the usage of that API.
> Problems were found especially in network card drivers.

This is really useful -- but surely it shouldn't be x86-specific?

All the code except the hooks in the architecture's dma_map_single() et
al functions could be generic, couldn't it?

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

