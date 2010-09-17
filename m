From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
 ip_fragment
Date: Fri, 17 Sep 2010 16:43:56 -0700 (PDT)
Message-ID: <20100917.164356.22528384.davem@davemloft.net>
References: <20100903044941.GA28300@gondor.apana.org.au>
	<20100915173209.GB9086@stratus.com>
	<20100917065117.GA9577@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bandan.das@stratus.com, bunk@kernel.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100917065117.GA9577@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 17 Sep 2010 14:51:17 +0800

> On Wed, Sep 15, 2010 at 01:32:09PM -0400, Bandan Das wrote:
>>
>> Sorry for the late response. Here's a patch that I put up based on Herbert's
>> suggestions. I ofcourse don't see the problem anymore after 
>> commit 87f94b4e91dc042620c527f3c30c37e5127ef757 but a generic helper such as this 
>> can be used anytime the bridge code is sending a packet over to the IP layer. 
>> Compile tested only but based on responses, will test it before submitting a 
>> final change. Also added it at two places where I know we do send a packet over to
>> the IP layer. I will add it at other places later as I come across them.
> 
> Looks fine to me.

Bandan, please submit this formally with proper commit message,
signoff, also the new function you added needs a minor coding
style fix, there needs to be a space after "if" and the openning
left parenthesis.

Thanks.
