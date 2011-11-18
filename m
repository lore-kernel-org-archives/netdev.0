From: David Miller <davem@davemloft.net>
Subject: Re: [0/6] Replace LL_ALLOCATED_SPACE to allow needed_headroom
 adjustment
Date: Fri, 18 Nov 2011 15:01:57 -0500 (EST)
Message-ID: <20111118.150157.1046683437153798989.davem@davemloft.net>
References: <20111025115425.GA1530@gondor.apana.org.au>
	<20111025.231204.257472162924919077.davem@davemloft.net>
	<20111118121832.GA2868@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: herbert@gondor.hengli.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111118121832.GA2868@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Fri, 18 Nov 2011 20:18:32 +0800

> On Tue, Oct 25, 2011 at 11:12:04PM -0400, David Miller wrote:
>> From: Herbert Xu <herbert@gondor.hengli.com.au>
>> Date: Tue, 25 Oct 2011 13:54:25 +0200
>> 
>> > So I'm going to get rid of LL_ALLOCATED_SPACE completely and
>> > replace it with explicit references to the tailroom as it doesn't
>> > need the alignment anyway (The headroom needs alignment since
>> > we use it to ensure the head is aligned).
>> 
>> Ok.
> 
> Here are the patches that do this.  I also picked up one spot
> that should have used LL_ALLOCATED_SPACE but did not (see 2nd
> last patch).

This all looks good to me, applied to net-next, thanks!
