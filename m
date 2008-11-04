From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Have af-specific init_tempsel() initialize family
 field of temporary selector
Date: Tue, 04 Nov 2008 14:49:26 -0800 (PST)
Message-ID: <20081104.144926.65584309.davem@davemloft.net>
References: <20081104112424.GB11049@gondor.apana.org.au>
	<87ljvziuhn.fsf@natisbad.org>
	<20081104115228.GC11049@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arno@natisbad.org, netdev@vger.kernel.org,
	andreas.steffen@strongswan.org, martin@strongswan.org,
	kazunori@miyazawa.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50144
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757251AbYKDWtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 17:49:51 -0500
In-Reply-To: <20081104115228.GC11049@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 4 Nov 2008 19:52:28 +0800

> On Tue, Nov 04, 2008 at 12:46:44PM +0100, Arnaud Ebalard wrote:
> >
> > Sorry Herbert, my initial comment was misleading: the family is not set
> > in the selectors provided in the *XFRM_MSG_ACQUIRE*, which is not MIPv6 
> > related. I could check again, but I think the patch below will impact
> > all native key managers. Or did I miss something and there is a specific
> > reason why MIPv6 folks may be impacted?
> 
> Indeed, you're right.  I was thinking of SA creation.
> 
> > >> Reported-by: Andreas Steffen <andreas.steffen@strongswan.org>
> > >> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6, thanks.
