From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Better MWI workaround for 21143 rev 65 chip errata
Date: Sat, 12 Apr 2008 05:01:51 -0400
Message-ID: <48007A7F.7040109@garzik.org>
References: <20080325113909.82BF8C2B76@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	kyle@parisc-linux.org, zero@colonel-panic.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59378 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758516AbYDLJBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:01:55 -0400
In-Reply-To: <20080325113909.82BF8C2B76@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Bogendoerfer wrote:
> From: Peter Horton <zero@colonel-panic.org>
> 
> This patch works around the MWI bug on the DC21143 rev 65 Tulip by
> ensuring that the receive buffers don't end on a cache line boundary
> (as documented in the errata).
> 
> This patch is required for the MIPS based Cobalt Qube/RaQ as
> supporting the extra PCI commands seems to reduce the chance of a hard
> lockup between the Tulip and the PCI bridge.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> ---
> 
>  drivers/net/tulip/tulip.h      |    7 ++++++-
>  drivers/net/tulip/tulip_core.c |   19 +++++--------------
>  2 files changed, 11 insertions(+), 15 deletions(-)

applied


