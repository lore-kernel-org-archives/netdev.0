From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: skb_segment() questions
Date: Wed, 1 Apr 2009 10:02:10 +0000
Message-ID: <20090401100209.GC5970@ff.dom.local>
References: <20090329020701.GA9983@gondor.apana.org.au> <20090401091801.GA5970@ff.dom.local> <20090401092457.GB19847@gondor.apana.org.au> <20090401095049.GB5970@ff.dom.local> <20090401095352.GB20003@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Huang <jamesclhuang@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:64480 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbZDAKCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 06:02:22 -0400
Received: by rv-out-0506.google.com with SMTP id f9so3547348rvb.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2009 03:02:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090401095352.GB20003@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2009 at 05:53:52PM +0800, Herbert Xu wrote:
> On Wed, Apr 01, 2009 at 09:50:50AM +0000, Jarek Poplawski wrote:
> >
> > I guess you mean non-linear skb with a header smaller than mtu? Well,
> > if it's the most common case now, I agree.
> 
> The common case is the path stemming from the TCP stack, where
> we always construct skb's with the entire payload in page frags,
> and only the header is placed in skb->data.

OK, then let's forget about this patch.

Thanks for the explanation,
Jarek P.
