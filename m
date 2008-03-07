From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Fri, 7 Mar 2008 04:10:44 +0100
Message-ID: <20080307031044.GF21185@wotan.suse.de>
References: <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com> <20080305000637.GA1510@wotan.suse.de> <20080304.161003.129716254.davem@davemloft.net> <Pine.LNX.4.64.0803051257030.30742@schroedinger.engr.sgi.com> <20080306025758.GB27150@wotan.suse.de> <Pine.LNX.4.64.0803061453360.16212@schroedinger.engr.sgi.com> <20080307022355.GB21185@wotan.suse.de> <Pine.LNX.4.64.0803061825120.29527@schroedinger.engr.sgi.com> <20080307023223.GD21185@wotan.suse.de> <Pine.LNX.4.64.0803061841220.29959@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com,
	dada1@cosmosbay.com
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:57192 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbYCGDKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 22:10:46 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803061841220.29959@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 06:54:19PM -0800, Christoph Lameter wrote:
> > It doesn't say start of cache line. It says align them *on* cachelines.
> > 2 32 byte objects on a 64 byte cacheline are aligned on the cacheline.
> > 2.67 24 bytes objects on a 64 byte cacheline are not aligned on the
> > cacheline.
> 
> 2 32 byte objects means only one is aligned on a cache line.
> 
> Certainly cacheline contention is reduced and performance potentially 
> increased if there are less objects in a cacheline.
> 
> The same argument can be made of aligning 8 byte objects on 32 byte 
> boundaries. Instead of 8 objects per cacheline you only have two. Why 8?
> 
> Isnt all of this a bit arbitrary and contrary to the intend of avoiding 
> cacheline contention?

No, it *is not about avoiding cacheline contention*. As such, the rest
of what you wrote below about smp_align etc is rubbish.

Can you actually read what I posted?

