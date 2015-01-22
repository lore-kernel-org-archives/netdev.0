From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Thu, 22 Jan 2015 20:50:24 +1100
Message-ID: <20150122095024.GA5281@gondor.apana.org.au>
References: <20150120153556.GJ20315@casper.infradead.org>
 <20150121050819.GA23062@gondor.apana.org.au>
 <20150121093722.GM20315@casper.infradead.org>
 <20150121093836.GA25489@gondor.apana.org.au>
 <20150121094928.GN20315@casper.infradead.org>
 <20150121095837.GA25750@gondor.apana.org.au>
 <20150121102346.GQ20315@casper.infradead.org>
 <20150122063501.GA3746@gondor.apana.org.au>
 <20150122072030.GA4039@gondor.apana.org.au>
 <20150122090518.GA30859@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150122090518.GA30859@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 22, 2015 at 09:05:18AM +0000, Thomas Graf wrote:
>
> What did you think of the idea to let the user store the walker
> bit for rhashtable?

The problem with that is the bit is needed to indicate special
walker objects which the user won't be able to decipher (see
xfrm_state_walk).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
