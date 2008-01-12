From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [UPDATED PATCH] SGISEEQ: use cached memory access to make driver
 work on IP28
Date: Sat, 12 Jan 2008 17:23:42 -0500
Message-ID: <47893DEE.1050807@pobox.com>
References: <20071202103312.75E51C2EB5@solo.franken.de> <47671FEE.90103@pobox.com> <20071218103006.GA18598@alpha.franken.de> <476867F5.3070006@pobox.com> <20071219124235.GA7550@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34031 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755107AbYALWXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 17:23:46 -0500
In-Reply-To: <20071219124235.GA7550@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Bogendoerfer wrote:
> - Use inline functions for dma_sync_* instead of macros 
> - added Kconfig change to make selection for similair SGI boxes easier
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> ---
> 
>  drivers/net/Kconfig   |    2 +-
>  drivers/net/sgiseeq.c |   64 ++++++++++++++++++++++++++-----------------------
>  2 files changed, 35 insertions(+), 31 deletions(-)

applied


