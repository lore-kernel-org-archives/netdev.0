From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx instead of MSI-X
Date: Mon, 25 Oct 2010 23:38:53 +0100
Message-ID: <20101025223853.GD15074@solarflare.com>
References: <20101025111235.GA2024@emulex.com> <20101025.120943.189699949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: somnath.kotur@emulex.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50747 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab0JYWi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 18:38:57 -0400
Content-Disposition: inline
In-Reply-To: <20101025.120943.189699949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Somnath Kotur <somnath.kotur@emulex.com>
> Date: Mon, 25 Oct 2010 16:42:35 +0530
> 
> > By default, be2net uses MSIx wherever possible.
> > Adding a module parameter to use INTx for users who do not want to use MSIx.
> > 
> > Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> 
> Either add a new ethtool flag, or use the PCI subsystem facilities
> for tweaking things to implement this.
>
> Do not use a module option, otherwise every other networking driver
> author will get the same "cool" idea, give the module option
> different names, and the resulting user experience is terrible.

This has already happened, sadly.  So far as I can see it's mostly done
to allow users to work around systems with broken MSIs; I'm not aware of
any other reason to prefer legacy interrupts.  However, the PCI subsystem
already implements a blacklist and a kernel parameter for disabling MSIs
on these systems.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
