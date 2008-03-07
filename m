From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Fri, 7 Mar 2008 04:22:51 +0100
Message-ID: <20080307032251.GG21185@wotan.suse.de>
References: <20080304.161003.129716254.davem@davemloft.net> <Pine.LNX.4.64.0803051257030.30742@schroedinger.engr.sgi.com> <20080306025758.GB27150@wotan.suse.de> <Pine.LNX.4.64.0803061453360.16212@schroedinger.engr.sgi.com> <20080307022355.GB21185@wotan.suse.de> <Pine.LNX.4.64.0803061825120.29527@schroedinger.engr.sgi.com> <20080307023223.GD21185@wotan.suse.de> <Pine.LNX.4.64.0803061841220.29959@schroedinger.engr.sgi.com> <20080307031044.GF21185@wotan.suse.de> <Pine.LNX.4.64.0803061916580.30259@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com,
	dada1@cosmosbay.com
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48610 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755473AbYCGDWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 22:22:52 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803061916580.30259@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 07:18:54PM -0800, Christoph Lameter wrote:
> On Fri, 7 Mar 2008, Nick Piggin wrote:
> 
> > No, it *is not about avoiding cacheline contention*. As such, the rest
> > of what you wrote below about smp_align etc is rubbish.
> > 
> > Can you actually read what I posted?
> 
> I am trying but it barely makes sense. You first state that it 
> is *not* about avoiding cacheline contention and then argue that it 
> reduces cacheline contention.

Where do I argue that it reduces cacheline contention? All arguments
I made apply to a UP system equally.

