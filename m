From: David Miller <davem@davemloft.net>
Subject: Re: ssh server etc doesn't work anymore with net-2.6
Date: Sun, 11 Apr 2010 14:43:13 -0700 (PDT)
Message-ID: <20100411.144313.71127091.davem@davemloft.net>
References: <20100411100902.GA20141@gondor.apana.org.au>
	<20100411120403.GA20565@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yinghai@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100411120403.GA20565@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 11 Apr 2010 20:04:03 +0800

> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> 
>> After looking at the actual net-2.6 tree I see that it is actually
>> CHECKSUM_PARTIAL that caused this breakage.
>> 
>> The fact that when this was first implemented we didn't use hw
>> checksums on dataless packets might not have been an oversight
>> after all.
> 
> Looks like I was too quick to blame the hardware, the synack
> code can't handle CHECKSUM_PARTIAL so this is probably the real
> cause.
> 
> I will send patches to fix this.

Thanks a lot for figuring this out.

I'll put my original patch (with fixed commit log message!)
and your fixes into net-next-2.6
