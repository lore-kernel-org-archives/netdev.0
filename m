From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] net: Add skb_gro_receive
Date: Mon, 15 Dec 2008 23:42:42 -0800 (PST)
Message-ID: <20081215.234242.98704610.davem@davemloft.net>
References: <20081213013420.GA13549@gondor.apana.org.au>
	<E1LBJPf-0003Yr-H2@gondolin.me.apana.org.au>
	<20081213025246.GA14173@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	bhutchings@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751946AbYLPHml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 02:42:41 -0500
In-Reply-To: <20081213025246.GA14173@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 13 Dec 2008 13:52:46 +1100

> On Sat, Dec 13, 2008 at 12:35:23PM +1100, Herbert Xu wrote:
> > net: Add skb_gro_receive
> > 
> > This patch adds the helper skb_gro_receive to merge packets for
> > GRO.  The current method is to allocate a new header skb and then
> > chain the original packets to its frag_list.  This is done to
> > make it easier to integrate into the existing GSO framework.
> > 
> > In future as GSO is moved into the drivers, we can undo this and
> > simply chain the original packets together.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Looks like I forgot to stop the merging at 64K.  Here is an update
> with the check added.

Applied.
