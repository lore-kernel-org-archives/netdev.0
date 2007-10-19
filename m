From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/8] [MV643XX_ETH] Move ethernet register definitions into private header
Date: Fri, 19 Oct 2007 13:09:57 +0200
Message-ID: <20071019110957.GL16037@xi.wantstofly.org>
References: <20071019021010.GD16037@xi.wantstofly.org> <20071019083048.GA16865@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:53329 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbXJSLJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 07:09:59 -0400
Content-Disposition: inline
In-Reply-To: <20071019083048.GA16865@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 09:30:48AM +0100, Christoph Hellwig wrote:

> > Move the mv643xx's ethernet-related register definitions from
> > include/linux/mv643xx.h into drivers/net/mv643xx_eth.h, since
> > they aren't of any use outside the ethernet driver.
> > 
> > Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> > Acked-by: Tzachi Perelstein <tzachi@marvell.com>
> > 
> > Index: linux-2.6/drivers/net/mv643xx_eth.h
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/mv643xx_eth.h
> > +++ linux-2.6/drivers/net/mv643xx_eth.h
> > @@ -7,7 +7,7 @@
> >  #include <linux/workqueue.h>
> >  #include <linux/mii.h>
> >  
> > -#include <linux/mv643xx.h>
> > +#include <linux/mv643xx_eth.h>
> 
> Isn't it a little too confusing to have two headers with the same name,
> one in drivers/net and one in include/linux?

Perhaps we can fold the drivers/net one into drivers/net/mv643xx_eth.c?
Since nothing else includes drivers/net/mv643xx_eth.h anyway, there's
not much point in having it separate.
