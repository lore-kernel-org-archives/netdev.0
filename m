From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Fri, 25 Jul 2008 02:54:56 -0700 (PDT)
Message-ID: <20080725.025456.68612813.davem@davemloft.net>
References: <20080723.234556.98132946.davem@davemloft.net>
	<E1KM0Wl-0001zC-00@gondolin.me.apana.org.au>
	<20080725074109.GA16747@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53899
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750934AbYGYJy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 05:54:56 -0400
In-Reply-To: <20080725074109.GA16747@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 25 Jul 2008 15:41:09 +0800

> On Thu, Jul 24, 2008 at 09:06:39PM +0800, Herbert Xu wrote:
> >
> > Indeed, this is long overdue.  I'm going to spend a few cycles on
> > this.  I'll start by moving the common code into net/xfrm/ipcomp.c
> > so that I don't have to do it twice later.
> 
> Here is the first part:
> 
> ipsec: ipcomp - Merge IPComp implementations
> 
> This patch merges the IPv4/IPv6 IPComp implementations since most
> of the code is identical.  As a result future enhancements will no
> longer need to be duplicated.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This is really nice :-)

Applied, thanks!
