From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Mon, 23 Oct 2017 21:01:46 -0700
Message-ID: <20171024040144.bf2cvq7p6zwg2e5k@ast-mbp>
References: <20171023181857.GA25379@embeddedor.com>
 <20171024032508.GC28462@gondor.apana.org.au>
 <20171023225043.Horde.R0FvJkHEmPPjnRNzKMOrPb3@gator4166.hostgator.com>
 <20171024035320.GA29795@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:52378 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdJXEBu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 00:01:50 -0400
Content-Disposition: inline
In-Reply-To: <20171024035320.GA29795@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 11:53:20AM +0800, Herbert Xu wrote:
> On Mon, Oct 23, 2017 at 10:50:43PM -0500, Gustavo A. R. Silva wrote:
> > 
> > Quoting Herbert Xu <herbert@gondor.apana.org.au>:
> > 
> > >On Mon, Oct 23, 2017 at 01:18:57PM -0500, Gustavo A. R. Silva wrote:
> > >>Use BUG_ON instead of if condition followed by BUG.
> > >>
> > >>This issue was detected with the help of Coccinelle.
> > >>
> > >>Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> > >
> > >I think this patch is terrible.  Why on earth is Coccinelle even
> > >warning about this?
> > >
> > >If anything we should be converting these constructs to not use
> > >BUG.
> > >
> > 
> > Yeah, and under this assumption the original code is even worse.
> 
> No your patch makes it worse.  The original construct makes it
> clear that the conditional is real code and not just some debugging
> aid.
> 
> With your patch, real code is now inside BUG_ON.

fwiw I had the same argument earlier:
https://lkml.org/lkml/2017/10/9/1139
