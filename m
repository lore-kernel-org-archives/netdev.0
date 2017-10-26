From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Thu, 26 Oct 2017 05:47:45 -0500
Message-ID: <20171026054745.Horde.IgJuLhgV7tprdH0lZ5Pdj0U@gator4166.hostgator.com>
References: <20171024035320.GA29795@gondor.apana.org.au>
 <20171024.174842.272234711073180328.davem@davemloft.net>
 <20171025040541.GA1999@gondor.apana.org.au>
 <20171025.132222.1438740282932861791.davem@davemloft.net>
 <20171025072800.GQ3323@secunet.com>
 <20171025114351.Horde.MQ4XGlIueQ50FhD0JRZ9B-o@gator4166.hostgator.com>
 <20171025193835.Horde.awZHiBVl04eXjKWA7saVTeB@gator4166.hostgator.com>
 <20171026063625.GA8783@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026063625.GA8783@gondor.apana.org.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

Quoting Herbert Xu <herbert@gondor.apana.org.au>:

> On Wed, Oct 25, 2017 at 07:38:35PM -0500, Gustavo A. R. Silva wrote:
>>
>> I don't think we want something like:
>>
>> bool err;
>>
>> err = build_spdinfo(r_skb, net, sportid, seq, *flags) < 0 ? true : false;
>> BUG_ON(err);
>
> How about
>
> 	int err;
>
> 	err = build_spdinfo(r_skb, net, sportid, seq, *flags);
> 	BUG_ON(err < 0);
>

I like it.

Thanks
--
Gustavo A. R. Silva
