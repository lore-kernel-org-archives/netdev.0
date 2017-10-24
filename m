From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Mon, 23 Oct 2017 22:57:04 -0500
Message-ID: <20171023225704.Horde.w2mxLEby5NdODWSnvTolC2g@gator4166.hostgator.com>
References: <20171023181857.GA25379@embeddedor.com>
 <20171024032508.GC28462@gondor.apana.org.au>
 <20171023225043.Horde.R0FvJkHEmPPjnRNzKMOrPb3@gator4166.hostgator.com>
 <20171024035320.GA29795@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024035320.GA29795@gondor.apana.org.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quoting Herbert Xu <herbert@gondor.apana.org.au>:

> On Mon, Oct 23, 2017 at 10:50:43PM -0500, Gustavo A. R. Silva wrote:
>>
>> Quoting Herbert Xu <herbert@gondor.apana.org.au>:
>>
>> >On Mon, Oct 23, 2017 at 01:18:57PM -0500, Gustavo A. R. Silva wrote:
>> >>Use BUG_ON instead of if condition followed by BUG.
>> >>
>> >>This issue was detected with the help of Coccinelle.
>> >>
>> >>Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> >
>> >I think this patch is terrible.  Why on earth is Coccinelle even
>> >warning about this?
>> >
>> >If anything we should be converting these constructs to not use
>> >BUG.
>> >
>>
>> Yeah, and under this assumption the original code is even worse.
>
> No your patch makes it worse.  The original construct makes it
> clear that the conditional is real code and not just some debugging
> aid.
>
> With your patch, real code is now inside BUG_ON.
>

What is the reason for BUG_ON to exist then if it makes the code worse  
than an _if_ condition followed by BUG?

Thanks
--
Gustavo A. R. Silva
