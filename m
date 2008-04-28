From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] ARCH 2.6.25.y: Fix 32-bit x86 MSI-X
	allocation leakage
Date: Mon, 28 Apr 2008 10:38:02 -0700
Message-ID: <20080428173801.GA933@kroah.com>
References: <20080426010025.7212.3940.stgit@scrappy.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:56164 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763515AbYD1RiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 13:38:20 -0400
Content-Disposition: inline
In-Reply-To: <20080426010025.7212.3940.stgit@scrappy.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2008 at 06:00:26PM -0700, PJ Waskiewicz wrote:
> This bug was introduced in the 2.6.24 i386/x86_64 tree merge, where
> MSI-X vector allocation will eventually fail.  The cause is the new
> bit array tracking used vectors is not getting cleared properly on
> IRQ destruction on the 32-bit APIC code.
> 
> This can be seen easily using the ixgbe 10 GbE driver on multi-core
> systems by simply loading and unloading the driver a few times.
> Depending on the number of available vectors on the host system, the
> MSI-X allocation will eventually fail, and the driver will only be
> able to use legacy interrupts.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> ---

When sending patches to -stable, please add "CC: stable
<stable@kernel.org> to the patch itself in the signed-off-by area, that
way we get notified automatically when it goes into Linus's tree so that
we can then know to apply it to the tree.  Otherwise it's a tough job to
try to track all of these knowing when to watch out for them to be
committed.

Can you please resend them to stable@kernel.org when they do go into
Linus's tree?

thanks,

greg k-h
