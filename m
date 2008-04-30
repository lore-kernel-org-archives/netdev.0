From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] ARCH 2.6.24.y: Fix 32-bit x86 MSI-X
	allocation leakage
Date: Wed, 30 Apr 2008 10:15:57 -0700
Message-ID: <20080430171557.GB23269@kroah.com>
References: <20080426005950.7155.44626.stgit@scrappy.jf.intel.com> <20080429102235.GI23198@elte.hu> <20080429164744.GA29911@kroah.com> <20080429220115.GE2302@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, stable@kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34875 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757141AbYD3Rbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 13:31:49 -0400
Content-Disposition: inline
In-Reply-To: <20080429220115.GE2302@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2008 at 12:01:15AM +0200, Ingo Molnar wrote:
> 
> * Greg KH <greg@kroah.com> wrote:
> 
> > On Tue, Apr 29, 2008 at 12:22:35PM +0200, Ingo Molnar wrote:
> > > 
> > > * PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> wrote:
> > > 
> > > > This bug was introduced in the 2.6.24 i386/x86_64 tree merge, where 
> > > > MSI-X vector allocation will eventually fail.  The cause is the new 
> > > > bit array tracking used vectors is not getting cleared properly on IRQ 
> > > > destruction on the 32-bit APIC code.
> > > 
> > > Greg, please fix the commit message - this is a separate bug that 
> > > has nothing to do with the unification.
> > 
> > What should I fix the commit message to be?  I copied the same commit 
> > message that went into Linus's tree.  We should be consistent :)
> 
> instead of:
> 
>    This bug was introduced in the 2.6.24 i386/x86_64 tree merge,
> 
> use:
> 
>    This bug was introduced in the 2.6.24 lguest merge,

Ok, I've used this one for both .24 and .25 stable releases.

thanks,

greg k-h
