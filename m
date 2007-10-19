From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH 2/8] [MV643XX_ETH] Move ethernet register definitions into private header
Date: Fri, 19 Oct 2007 05:56:54 -0700
Message-ID: <20071019125654.GA11495@xyzzy.farnsworth.org>
References: <20071019021010.GD16037@xi.wantstofly.org> <20071019083048.GA16865@infradead.org> <20071019110957.GL16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:50575 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1765935AbXJSM44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 08:56:56 -0400
Content-Disposition: inline
In-Reply-To: <20071019110957.GL16037@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 01:09:57PM +0200, Lennert Buytenhek wrote:
> On Fri, Oct 19, 2007 at 09:30:48AM +0100, Christoph Hellwig wrote:
> > Isn't it a little too confusing to have two headers with the same name,
> > one in drivers/net and one in include/linux?
> 
> Perhaps we can fold the drivers/net one into drivers/net/mv643xx_eth.c?
> Since nothing else includes drivers/net/mv643xx_eth.h anyway, there's
> not much point in having it separate.

Sounds good to me.  Please add a patch to do so.

-Dale
