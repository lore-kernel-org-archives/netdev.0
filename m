From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 3/3] use SLAB_ALIGN_SMP
Date: Mon, 3 Mar 2008 11:10:50 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803031110050.6917@schroedinger.engr.sgi.com>
References: <20080303093449.GA15091@wotan.suse.de>  <20080303093624.GC15091@wotan.suse.de>
  <47CBCAB0.2040604@cosmosbay.com>  <20080303124142.GB13138@wotan.suse.de>
 <47CBF683.10201@cosmosbay.com>  <20080303134622.GD13138@wotan.suse.de>
 <84144f020803030553s35a40dd8yf88585ccd5a599fd@mail.gmail.com>
 <47CC080E.9010203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Nick Piggin <npiggin@suse.de>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:46942 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757263AbYCCTKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 14:10:50 -0500
In-Reply-To: <47CC080E.9010203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Mar 2008, Eric Dumazet wrote:

> This reminds me a previous attempt of removing SLAB_HWCACHE_ALIGN
> 
> http://kernel.org/pub/linux/kernel/people/christoph/patch-archive/2007/2.6.21-rc6/remove_hwcache_align
> 
> At that time Christoph didnt took into account the CONFIG_SMP thing (false
> sharing avoidance), but also that L1_CACHE_SIZE is a compile constant, that
> can differs with cache_line_size()

If cache_line_size() is universally available then we can specify it as 
the alignment parameter to kmem_cache_create(). That would allow removal 
of SLAB_HWCACHE_ALIGN.

