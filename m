From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Mon, 3 Mar 2008 12:10:59 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com>
References: <20080303093449.GA15091@wotan.suse.de>
 <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com>
 <20080303200613.GC8974@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:49039 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754247AbYCCULA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 15:11:00 -0500
In-Reply-To: <20080303200613.GC8974@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Mar 2008, Nick Piggin wrote:

> > If they are already not cache line aligned then we can make them as 
> > dense as possible. That is what SLUB does.
> 
> Because when you specify HWCACHE_ALIGN, it means that you want the object
> not to cross cacheline boundaries for at least cache_line_size() bytes.
> SLAB does this. SLUB does not without this patch.

HWCACHE_ALIGN means that you want the object to be aligned at 
cacheline boundaries for optimization. Why does crossing cacheline 
boundaries matter in this case?

