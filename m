From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Wed, 5 Mar 2008 01:06:37 +0100
Message-ID: <20080305000637.GA1510@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de> <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com> <20080303200613.GC8974@wotan.suse.de> <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com> <20080303201701.GF8974@wotan.suse.de> <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:53841 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935275AbYCEAGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 19:06:41 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 01:16:44PM -0800, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Nick Piggin wrote:
> 
> > > HWCACHE_ALIGN means that you want the object to be aligned at 
> > > cacheline boundaries for optimization. Why does crossing cacheline 
> > > boundaries matter in this case?
> > 
> > No, HWCACHE_ALIGN means that you want the object not to cross cacheline
> > boundaries for at least cache_line_size() bytes. You invented new
> 
> Interesting new definition....

Huh?? It is not a new definition, it is exactly what SLAB does. And
then you go and do something different and claim that you follow
what slab does.

