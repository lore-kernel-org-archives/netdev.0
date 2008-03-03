From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Mon, 3 Mar 2008 11:06:55 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093529.GB15091@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:59307 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752391AbYCCTG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 14:06:56 -0500
In-Reply-To: <20080303093529.GB15091@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Mar 2008, Nick Piggin wrote:

> Introduce SLAB_SMP_ALIGN, for allocations where false sharing must be
> minimised on SMP systems.

Mandatory alignment are specified as a parameter to kmem_cache_create not 
as flags. Ycan specify the alignment as a parameter. i.e. L1_CACHE_BYTES 
or cache_line_size().

Maybe we should drop SLAB_HWCACHE_ALIGN because of the confusion is 
creates because it seems that flags can be used to enforce alignments?


