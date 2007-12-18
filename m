From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [UPDATED PATCH] SGISEEQ: use cached memory access to make driver
 work on IP28
Date: Mon, 17 Dec 2007 20:18:38 -0500
Message-ID: <47671FEE.90103@pobox.com>
References: <20071202103312.75E51C2EB5@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34193 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174AbXLRBSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 20:18:42 -0500
In-Reply-To: <20071202103312.75E51C2EB5@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Bogendoerfer wrote:
> SGI IP28 machines would need special treatment (enable adding addtional
> wait states) when accessing memory uncached. To avoid this pain I changed
> the driver to use only cached access to memory.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> ---
> 
> Changes to last version:
> - Use inline functions for dma_sync_* instead of macros (suggested by Ralf)
> - added Kconfig change to make selection for similair SGI boxes easier

hrm, could you rediff?  it doesn't seem to apply


