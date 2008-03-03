From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Mon, 3 Mar 2008 12:09:43 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803031208400.16049@schroedinger.engr.sgi.com>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093529.GB15091@wotan.suse.de>
 <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com>
 <20080303200355.GB8974@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:41935 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750893AbYCCUJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 15:09:44 -0500
In-Reply-To: <20080303200355.GB8974@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Mar 2008, Nick Piggin wrote:

> > Mandatory alignment are specified as a parameter to kmem_cache_create not 
> > as flags.
> 
> Not after this patch.

You want two ways of specifying alignments?

> > Ycan specify the alignment as a parameter. i.e. L1_CACHE_BYTES 
> > or cache_line_size().
> 
> We don't want either of those, though.
> 
> I don't see why this is a problem to do inside slab.

I am not sure why you need to have two ways of specifying alignments.
 
