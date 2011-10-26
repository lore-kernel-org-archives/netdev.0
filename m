From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
 causes kernel oops
Date: Tue, 25 Oct 2011 23:12:04 -0400 (EDT)
Message-ID: <20111025.231204.257472162924919077.davem@davemloft.net>
References: <20111020.053050.383972361986316046.davem@davemloft.net>
	<20111020093541.GA3024@gondor.apana.org.au>
	<20111025115425.GA1530@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: herbert@gondor.hengli.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111025115425.GA1530@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Tue, 25 Oct 2011 13:54:25 +0200

> So I'm going to get rid of LL_ALLOCATED_SPACE completely and
> replace it with explicit references to the tailroom as it doesn't
> need the alignment anyway (The headroom needs alignment since
> we use it to ensure the head is aligned).

Ok.
