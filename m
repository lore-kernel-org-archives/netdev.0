From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 03/16] dma-debug: add hash functions for
 dma_debug_entries
Date: Tue, 13 Jan 2009 08:59:39 +0000
Message-ID: <1231837179.25018.2816.camel@macbook.infradead.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
	 <1231517970-20288-4-git-send-email-joerg.roedel@amd.com>
	 <20090113005118.82f5037b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joerg Roedel <joerg.roedel@amd.com>, linux-kernel@vger.kernel.org,
	mingo@redhat.com, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54808 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbZAMI7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 03:59:49 -0500
In-Reply-To: <20090113005118.82f5037b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-13 at 00:51 -0800, Andrew Morton wrote:
> This all looks like an exotically large amount of code for a debug
> thingy?

Perhaps so, but it's a useful debug thingy which lets us debug _very_
common problems in drivers, which many people are unlikely to notice
without this 'assistance'. 

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

