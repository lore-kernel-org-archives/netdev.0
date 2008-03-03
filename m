From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Mon, 3 Mar 2008 21:03:55 +0100
Message-ID: <20080303200355.GB8974@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093529.GB15091@wotan.suse.de> <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:42180 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864AbYCCUD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 15:03:57 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 11:06:55AM -0800, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Nick Piggin wrote:
> 
> > Introduce SLAB_SMP_ALIGN, for allocations where false sharing must be
> > minimised on SMP systems.
> 
> Mandatory alignment are specified as a parameter to kmem_cache_create not 
> as flags.

Not after this patch.

> Ycan specify the alignment as a parameter. i.e. L1_CACHE_BYTES 
> or cache_line_size().

We don't want either of those, though.

I don't see why this is a problem to do inside slab.
