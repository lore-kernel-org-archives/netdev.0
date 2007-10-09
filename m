From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [IPSEC]: Move common output code to xfrm_output
Date: Mon, 08 Oct 2007 18:18:58 -0700 (PDT)
Message-ID: <20071008.181858.16492462.davem@davemloft.net>
References: <E1Ieqnr-0000o7-00@gondolin.me.apana.org.au>
	<20071008.171717.71577244.davem@davemloft.net>
	<20071009010257.GA14117@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751463AbXJIBS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 21:18:59 -0400
In-Reply-To: <20071009010257.GA14117@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 9 Oct 2007 09:02:57 +0800

> On Mon, Oct 08, 2007 at 05:17:17PM -0700, David Miller wrote:
> > 
> > Could you submit a 2.6.23 version of just the ipv4 fix?
> > It might be interesting to determine why it was omitted,
> > perhaps it was an oversight, and it probably predates the
> > addition of skb_reset_*().
> 
> OK I double-checked and it isn't necessary at all for IPv4 as
> the mode output function already sets the correct value in it.
> 
> It's needed for IPv6 because the mode output functions there
> uses it to store a pointer to the NH pointer.
> 
> So no changes are necessary.

Thanks for doing this research.
