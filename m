From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Sat, 25 Apr 2009 00:31:14 +0800
Message-ID: <20090424163114.GA31659@gondor.apana.org.au>
References: <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090424163009.GA31585@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39008 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753135AbZDXQbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 12:31:19 -0400
Content-Disposition: inline
In-Reply-To: <20090424163009.GA31585@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 25, 2009 at 12:30:09AM +0800, Herbert Xu wrote:
>
> > This was using a net-next pulled 1/2 hour ago.  The only patch was your  
> > GRO patch applied to myri10ge.  Do you have some other local patch
> > which might be helping you?
> 
> I was using Linus's tree + the GRO patches from net-next.  I do
> have two further optimisation patches applied but they don't
> actually make much difference (I made them while trying to figure
> out why cxgb3's GRO became slow again, which turned out to be sender
> related).

I'll also retest using net-next.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
