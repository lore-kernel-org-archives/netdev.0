From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Tue, 11 Mar 2008 08:13:31 +0100
Message-ID: <20080311071330.GA20271@wotan.suse.de>
References: <20080303200355.GB8974@wotan.suse.de> <Pine.LNX.4.64.0803031208400.16049@schroedinger.engr.sgi.com> <20080303201211.GE8974@wotan.suse.de> <Pine.LNX.4.64.0803031216430.3110@schroedinger.engr.sgi.com> <20080303202411.GH8974@wotan.suse.de> <Pine.LNX.4.64.0803031327330.4375@schroedinger.engr.sgi.com> <20080307043700.GI21185@wotan.suse.de> <Pine.LNX.4.64.0803062108210.1143@schroedinger.engr.sgi.com> <20080307051944.GJ21185@wotan.suse.de> <Pine.LNX.4.64.0803062120410.1215@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58643 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265AbYCKHNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2008 03:13:35 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803062120410.1215@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 09:26:24PM -0800, Christoph Lameter wrote:
> Internode alignment is 4k. If you need an object aligned like that then it 
> may be better to go to the page allocator.

I never got a reply about this. Again: how can the modern slab allocator
avoid the need for internode alignment in order to prevent cacheline
pingpong on vsmp? Because I'm going to resubmit the SMP_ALIGN patch.

Also, the last I heard about the HWCACHE_ALIGN from you is that it didn't
make sense... I see it's merged now, which I appreciate, but I think it is
really important that we're on the same page here, so let me know if it
still doesn't make sense.

Thanks,
Nick

