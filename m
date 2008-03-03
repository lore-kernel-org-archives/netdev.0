From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 3/3] use SLAB_ALIGN_SMP
Date: Mon, 3 Mar 2008 11:09:51 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803031109200.6917@schroedinger.engr.sgi.com>
References: <20080303093449.GA15091@wotan.suse.de>  <20080303093624.GC15091@wotan.suse.de>
  <47CBCAB0.2040604@cosmosbay.com>  <20080303124142.GB13138@wotan.suse.de>
 <47CBF683.10201@cosmosbay.com>  <20080303134622.GD13138@wotan.suse.de>
 <84144f020803030553s35a40dd8yf88585ccd5a599fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nick Piggin <npiggin@suse.de>, Eric Dumazet <dada1@cosmosbay.com>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:35951 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753184AbYCCTJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 14:09:52 -0500
In-Reply-To: <84144f020803030553s35a40dd8yf88585ccd5a599fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Mar 2008, Pekka Enberg wrote:

> At least historically SLAB_HWCACHE_ALIGN has been just a hint,
> although slab tries very hard to satisfy it (see the comments in
> mm/slab.c). Why do we need stronger guarantees than that, btw?

Its a hint. Alignment is specified as a parameter to kmem_cache_create not 
as a flag. Maybe we could remove SLAB_HWCACHE_ALIGN because it is causing 
so much confusion?
 
