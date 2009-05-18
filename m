From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: fix PPC DMA breakage
Date: Sun, 17 May 2009 21:16:58 -0700 (PDT)
Message-ID: <20090517.211658.245399748.davem@davemloft.net>
References: <20090515183924.GA29279@iram.es>
	<20090515235330.GC1727@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paubert@iram.es, tbm@cyrius.com, pacman@kosh.dhis.org,
	netdev@vger.kernel.org, matt@genesi-usa.com,
	benh@kernel.crashing.org, linuxppc-dev@ozlabs.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36513
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751379AbZERERA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:17:00 -0400
In-Reply-To: <20090515235330.GC1727@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Sat, 16 May 2009 01:53:30 +0200

> On Fri, May 15, 2009 at 08:39:24PM +0200, Gabriel Paubert wrote:
> 
>> After 2.6.29, PPC no more admits passing NULL to the dev parameter of
>> the DMA API. The result is a BUG followed by solid lock-up when the 
>> mv643xx_eth driver brings an interface up. The following patch makes 
>> the driver work on my Pegasos again; it is mostly a search and replace 
>> of NULL by mp->dev->dev.parent in dma allocation/freeing/mapping/unmapping
>> functions.
>> 
>> Signed-off-by: Gabriel Paubert <paubert@iram.es>
> 
> Acked-by: Lennert Buytenhek <buytenh@marvell.com>

Applied, thanks everyone.
