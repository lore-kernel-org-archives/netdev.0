From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Thu, 26 Oct 2017 14:36:26 +0800
Message-ID: <20171026063625.GA8783@gondor.apana.org.au>
References: <20171024035320.GA29795@gondor.apana.org.au>
 <20171024.174842.272234711073180328.davem@davemloft.net>
 <20171025040541.GA1999@gondor.apana.org.au>
 <20171025.132222.1438740282932861791.davem@davemloft.net>
 <20171025072800.GQ3323@secunet.com>
 <20171025114351.Horde.MQ4XGlIueQ50FhD0JRZ9B-o@gator4166.hostgator.com>
 <20171025193835.Horde.awZHiBVl04eXjKWA7saVTeB@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171025193835.Horde.awZHiBVl04eXjKWA7saVTeB@gator4166.hostgator.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2017 at 07:38:35PM -0500, Gustavo A. R. Silva wrote:
>
> I don't think we want something like:
> 
> bool err;
> 
> err = build_spdinfo(r_skb, net, sportid, seq, *flags) < 0 ? true : false;
> BUG_ON(err);

How about

	int err;

	err = build_spdinfo(r_skb, net, sportid, seq, *flags);
	BUG_ON(err < 0);

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
