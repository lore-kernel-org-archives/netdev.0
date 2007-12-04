From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPv6][IPsec] fix the address family for
 xfrm_state_lookup in xfrm_input
Date: Mon, 03 Dec 2007 22:54:41 -0800 (PST)
Message-ID: <20071203.225441.141248930.davem@davemloft.net>
References: <20071204142836.a864e30e.kazunori@miyazawa.org>
	<20071204054935.GA1747@gondor.apana.org.au>
	<4754F245.1070602@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37325
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750931AbXLDGym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 01:54:42 -0500
In-Reply-To: <4754F245.1070602@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Tue, 04 Dec 2007 15:23:01 +0900

> Herbert Xu wrote:
> > I'd prefer to put this in XFRM_SPI_SKB_CB instead because the xfrm
> > layer shouldn't really rely on dst->ops structures except on entry
> > and exit, like this:
> > 
> > [IPSEC]: Use the correct family for input state lookup
> > 
> > When merging the input paths of IPsec I accidentally left a hard-coded
> > AF_INET for the state lookup call.  This broke IPv6 obviously.  This
> > patch fixes by getting the input callers to specify the family through
> > skb->cb.
> > 
> > Credit goes to Kazunori Miyazawa for diagnosing this and providing an
> > initial patch.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > Cheers,
> 
> It works fine.

Patch applied, thanks everyone.
