From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/3] [IPSEC]: Forbid BEET + ipcomp for now
Date: Thu, 25 Oct 2007 09:06:18 +0800
Message-ID: <20071025010618.GA15154@gondor.apana.org.au>
References: <20071024145850.GA10589@gondor.apana.org.au> <E1Ikhi4-0002lv-00@gondolin.me.apana.org.au> <471F67AE.5010301@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Joakim Koskela <joakim.koskela@hiit.fi>, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1670 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752016AbXJYBHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 21:07:03 -0400
Content-Disposition: inline
In-Reply-To: <471F67AE.5010301@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 24, 2007 at 05:41:34PM +0200, Nicolas Dichtel wrote:
>
> >+	x->props.header_len = 0;
> >+	switch (x->props.mode) {
> >+	case XFRM_MODE_TRANSPORT:
> >+		break;
> >+	case XFRM_MODE_TUNNEL:
> >+		x->props.header_len += sizeof(struct iphdr);
> I think, the break statement is missing, is it ?

Indeed it is.  I'm going to fix this and repost all 3 patches.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
