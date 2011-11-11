From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 0/3] Move some Octeon support files out of staging.
Date: Thu, 10 Nov 2011 16:45:17 -0800
Message-ID: <20111111004517.GA32432@suse.de>
References: <1320971387-29343-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	David Daney <david.daney@cavium.com>
To: ddaney.cavm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49773 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752336Ab1KKAqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 19:46:31 -0500
Content-Disposition: inline
In-Reply-To: <1320971387-29343-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2011 at 04:29:44PM -0800, ddaney.cavm@gmail.com wrote:
> From: David Daney <david.daney@cavium.com>
> 
> First patch:
> 
> In preparation for my next set of patches to add device tree support
> for Octeon, move some files out of drivers/staging/octeon to common
> location.  There are two basic types of files I am moving:
> 
> 1) Register definition files.  Most Octeon register definition files
>    are in arch/mips/include/asm/octeon, put the rest there too.
> 
> 2) Low level packet port type probing code.  This is needed by both
>    the Ethernet driver and the code that fixes up the in-kernel device
>    trees.  Although new board pass a device tree to the kernel,
>    support of legacy boards requires that this probing code be used to
>    fix up an in-kernel device tree template.
> 
> 
> Second patch:
> 
> Update support for legacy boards.
> 
> 
> Third patch:
> 
> Seperate probing and initialization of packet ports.
> 
> 
> Since these are MIPS architecture files we could merge via Ralf's tree
> if approved.

If Ralf approves of these changes, that's fine with me and they can go
through his tree:
	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>


thanks,

greg k-h
