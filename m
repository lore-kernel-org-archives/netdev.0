From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Fri, 7 Mar 2008 06:23:18 +0100
Message-ID: <20080307052317.GK21185@wotan.suse.de>
References: <20080305002821.GD1510@wotan.suse.de> <Pine.LNX.4.64.0803051254570.30742@schroedinger.engr.sgi.com> <20080306024904.GA27150@wotan.suse.de> <Pine.LNX.4.64.0803061451230.16212@schroedinger.engr.sgi.com> <20080307020443.GA21185@wotan.suse.de> <Pine.LNX.4.64.0803061816430.28976@schroedinger.engr.sgi.com> <20080307022537.GC21185@wotan.suse.de> <Pine.LNX.4.64.0803061827040.29527@schroedinger.engr.sgi.com> <20080307023315.GE21185@wotan.suse.de> <Pine.LNX.4.64.0803061833140.29585@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:43450 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755794AbYCGFXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 00:23:19 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803061833140.29585@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 06:33:35PM -0800, Christoph Lameter wrote:
> On Fri, 7 Mar 2008, Nick Piggin wrote:
> 
> > On Thu, Mar 06, 2008 at 06:27:12PM -0800, Christoph Lameter wrote:
> > > On Fri, 7 Mar 2008, Nick Piggin wrote:
> > > 
> > > > > Is that really a noteworthy effect?
> > > > 
> > > > Yes.
> > > 
> > > Numbers?
> > 
> > Uhh... big number > small number
> 
> Can you quantify the effect?

It obviously won't be a great deal until if/when it starts getting
used more. The space savings on UP are just one reason why my approach
is better than using the static alignment annotations.

