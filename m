From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/6] Replace LL_ALLOCATED_SPACE to allow needed_headroom
	adjustment
Date: Fri, 18 Nov 2011 20:18:32 +0800
Message-ID: <20111118121832.GA2868@gondor.apana.org.au>
References: <20111020.053050.383972361986316046.davem@davemloft.net> <20111020093541.GA3024@gondor.apana.org.au> <20111025115425.GA1530@gondor.apana.org.au> <20111025.231204.257472162924919077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111025.231204.257472162924919077.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 11:12:04PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.hengli.com.au>
> Date: Tue, 25 Oct 2011 13:54:25 +0200
> 
> > So I'm going to get rid of LL_ALLOCATED_SPACE completely and
> > replace it with explicit references to the tailroom as it doesn't
> > need the alignment anyway (The headroom needs alignment since
> > we use it to ensure the head is aligned).
> 
> Ok.

Here are the patches that do this.  I also picked up one spot
that should have used LL_ALLOCATED_SPACE but did not (see 2nd
last patch).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
