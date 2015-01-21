From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Wed, 21 Jan 2015 20:58:37 +1100
Message-ID: <20150121095837.GA25750@gondor.apana.org.au>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
 <20150120145551.GH20315@casper.infradead.org>
 <20150120152149.GA3012@acer.localdomain>
 <20150120153556.GJ20315@casper.infradead.org>
 <20150121050819.GA23062@gondor.apana.org.au>
 <20150121093722.GM20315@casper.infradead.org>
 <20150121093836.GA25489@gondor.apana.org.au>
 <20150121094928.GN20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150121094928.GN20315@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 21, 2015 at 09:49:28AM +0000, Thomas Graf wrote:
>
> An entry can move between different tables and thus chains need to be
> marked to identify what list a lookup ended up searching in. It's not
> the nulls marker itself that is needed, it's the bits in the last next
> pointer identifying the list that the nulls marker allows to be used
> which are essential.

Can you describe in more detail how it's going to be used? I don't
see how I could use the bit if you need it to indicate the end of
the list.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
