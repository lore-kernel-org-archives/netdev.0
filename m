From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Rewrite e100_phys_id
Date: Thu, 26 Oct 2006 15:19:37 -0400
Message-ID: <20061026191937.GB11312@havoc.gtf.org>
References: <20061026191154.GG5591@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:16049 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S932274AbWJZTTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 15:19:43 -0400
To: Matthew Wilcox <matthew@wil.cx>
Content-Disposition: inline
In-Reply-To: <20061026191154.GG5591@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2006 at 01:11:55PM -0600, Matthew Wilcox wrote:
> 
> The motivator for this was to fix the sparse warning:
> 
> drivers/net/e100.c:2418:48: warning: cast truncates bits from constant
> value (83126e978d4fdf becomes 978d4fdf)
> drivers/net/e100.c:2419:37: warning: cast truncates bits from constant
> value (83126e978d4fdf becomes 978d4fdf)
> 
> Initially, I tried a quick fix, but when it ran into difficulties, I
> looked at tg3.c to see how it does it.  I liked their way better, so I
> rewrote e100.c to be similar.  It shaves ~700 bytes off the size of the
> driver, and a few bytes off the size of struct nic, so I think it's a
> win all round.  Tested on the internal interface of an HP Integrity rx2600.
> 
> Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Seems sane to me...  I'll pick it up, if Auke doesn't...

	Jeff



