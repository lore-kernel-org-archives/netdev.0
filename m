From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Mon, 3 Mar 2008 11:08:44 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com>
References: <20080303093449.GA15091@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:46596 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752977AbYCCTIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 14:08:44 -0500
In-Reply-To: <20080303093449.GA15091@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Mar 2008, Nick Piggin wrote:

> SLUB should pack even small objects nicely into cachelines if that is what
> has been asked for. Use the same algorithm as SLAB for this.

Why? SLAB does not cacheline align objects smaller than cache_line_size() 
/2. If they are already not cache line aligned then we can make them as 
dense as possible. That is what SLUB does.

