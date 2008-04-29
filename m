From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] ARCH 2.6.24.y: Fix 32-bit x86 MSI-X
	allocation leakage
Date: Tue, 29 Apr 2008 09:47:44 -0700
Message-ID: <20080429164744.GA29911@kroah.com>
References: <20080426005950.7155.44626.stgit@scrappy.jf.intel.com> <20080429102235.GI23198@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, stable@kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39219 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbYD2RLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 13:11:13 -0400
Content-Disposition: inline
In-Reply-To: <20080429102235.GI23198@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 12:22:35PM +0200, Ingo Molnar wrote:
> 
> * PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> wrote:
> 
> > This bug was introduced in the 2.6.24 i386/x86_64 tree merge, where 
> > MSI-X vector allocation will eventually fail.  The cause is the new 
> > bit array tracking used vectors is not getting cleared properly on IRQ 
> > destruction on the 32-bit APIC code.
> 
> Greg, please fix the commit message - this is a separate bug that has 
> nothing to do with the unification.

What should I fix the commit message to be?  I copied the same commit
message that went into Linus's tree.  We should be consistent :)

thanks,

greg k-h
