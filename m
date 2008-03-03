From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 3/3] use SLAB_ALIGN_SMP
Date: Mon, 3 Mar 2008 21:18:37 +0100
Message-ID: <20080303201837.GG8974@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093624.GC15091@wotan.suse.de> <47CBCAB0.2040604@cosmosbay.com> <20080303124142.GB13138@wotan.suse.de> <47CBF683.10201@cosmosbay.com> <20080303134622.GD13138@wotan.suse.de> <84144f020803030553s35a40dd8yf88585ccd5a599fd@mail.gmail.com> <Pine.LNX.4.64.0803031109200.6917@schroedinger.engr.sgi.com> <20080303201008.GD8974@wotan.suse.de> <Pine.LNX.4.64.0803031211100.16049@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:58035 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759430AbYCCUSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 15:18:38 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803031211100.16049@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 12:12:15PM -0800, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Nick Piggin wrote:
> 
> > Yeah, that's what I thought too, when I got confused by these new
> > SLUB semantics that you made up. Actually if you look at SLAB,
> > it has very precise and rational semantics. SLUB should respect that.
> 
> These crappy semantics are SLAB semantics that SLUB must support.

They are only crappy in SLUB. In SLAB they are actually useful.
