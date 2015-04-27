From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH][net-next][v2] xfrm: optimise the use of walk list header
 in xfrm_policy/state_walk
Date: Mon, 27 Apr 2015 12:37:02 +0200
Message-ID: <20150427103656.GK8928@secunet.com>
References: <1429693794-17256-1-git-send-email-roy.qing.li@gmail.com>
 <20150422091318.GA9719@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <roy.qing.li@gmail.com>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47759 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932371AbbD0KhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 06:37:10 -0400
Content-Disposition: inline
In-Reply-To: <20150422091318.GA9719@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 05:13:18PM +0800, Herbert Xu wrote:
> On Wed, Apr 22, 2015 at 05:09:54PM +0800, roy.qing.li@gmail.com wrote:
> > From: Li RongQing <roy.qing.li@gmail.com>
> > 
> > The walk from input is the list header, and marked as dead, and will
> > be skipped in loop.
> > 
> > list_first_entry() can be used to return the true usable value from
> > walk if walk is not empty
> > 
> > Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to ipsec-next, thanks everyone!
