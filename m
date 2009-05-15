From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mv643xx_eth: fix PPC DMA breakage
Date: Sat, 16 May 2009 01:53:30 +0200
Message-ID: <20090515235330.GC1727@mail.wantstofly.org>
References: <20090515183924.GA29279@iram.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tbm@cyrius.com,
	pacman@kosh.dhis.org, netdev@vger.kernel.org,
	Matt Sealey <matt@genesi-usa.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	LinuxPPC <linuxppc-dev@ozlabs.org>
To: Gabriel Paubert <paubert@iram.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:38307 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907AbZEOXxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 19:53:14 -0400
Content-Disposition: inline
In-Reply-To: <20090515183924.GA29279@iram.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 08:39:24PM +0200, Gabriel Paubert wrote:

> After 2.6.29, PPC no more admits passing NULL to the dev parameter of
> the DMA API. The result is a BUG followed by solid lock-up when the 
> mv643xx_eth driver brings an interface up. The following patch makes 
> the driver work on my Pegasos again; it is mostly a search and replace 
> of NULL by mp->dev->dev.parent in dma allocation/freeing/mapping/unmapping
> functions.
> 
> Signed-off-by: Gabriel Paubert <paubert@iram.es>

Acked-by: Lennert Buytenhek <buytenh@marvell.com>

Thanks for testing!
