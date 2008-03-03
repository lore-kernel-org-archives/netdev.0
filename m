From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Mon, 03 Mar 2008 23:35:44 +0200
Message-ID: <47CC6F30.50802@cs.helsinki.fi>
References: <20080303093449.GA15091@wotan.suse.de>  <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com>  <20080303200613.GC8974@wotan.suse.de>  <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com>  <20080303201701.GF8974@wotan.suse.de>  <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com> <84144f020803031330i2c0ea1f6kc5b02c8b26145797@mail.gmail.com> <Pine.LNX.4.64.0803031331340.4375@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nick Piggin <npiggin@suse.de>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58732 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbYCCVhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 16:37:00 -0500
In-Reply-To: <Pine.LNX.4.64.0803031331340.4375@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Christoph Lameter wrote:
> Well the guarantee can only be exploited if you would check the cacheline 
> sizes and the object size from the code that creates the slab cache. 
> Basically you would have to guestimate what the slab allocator is doing.
> 
> So the guarantee is basically meaningless. If the object is larger than a 
> cacheline then this will never work.

Yes, I know that. That's why I am asking why this matters. If there's 
some sort of regression because SLUB does HWCACHE_ALIGN bit differently, 
we need to fix that. Not that it necessarily means we have to change 
HWCACHE_ALIGN but I am assuming Nick has some reason why he wants to 
introduce the SMP alignment flag.

			Pekka
