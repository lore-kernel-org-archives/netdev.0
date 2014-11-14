From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/2] xfrm: Do not hash socket policies
Date: Fri, 14 Nov 2014 12:36:59 +0100
Message-ID: <20141114113659.GP6390@secunet.com>
References: <20141113090048.GA3120@gondor.apana.org.au>
 <20141113090811.GA3280@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45372 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933506AbaKNLhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 06:37:10 -0500
Content-Disposition: inline
In-Reply-To: <20141113090811.GA3280@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2014 at 05:08:11PM +0800, Herbert Xu wrote:
> On Thu, Nov 13, 2014 at 05:00:48PM +0800, Herbert Xu wrote:
> > Hi Steffen:
> > 
> > I'm working on converting the xfrm policy hashing over to RCU
> > due to performance complaints.  While doing this I noticed that
> > we're needlessly hashing socket policies.
> > 
> > Here are two patches to get rid of that and slightly clean things
> > up.
> 
> Oops that didn't work very well as I left out some rather important
> bits :)
> 
> Here is a second revision.

Both applied to ipsec-next, thanks Herbert!
