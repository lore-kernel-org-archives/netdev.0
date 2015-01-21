From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Wed, 21 Jan 2015 16:11:30 +1100
Message-ID: <20150121051130.GB23062@gondor.apana.org.au>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150120143154.GR14883@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 20, 2015 at 02:31:54PM +0000, Patrick McHardy wrote:
> 
> An alternative would be to set a flag in ht when a dump begins that
> indicates to skip resizing operations and on the end of the dump
> perform any resizing operations that might be necessary. Herbert
> disagrees though and he might be right.

It's a bit more complex than just a disagreement :)

See the email I just sent.  But the crucial thing is that postponed
resizing/rehashing during dumping is only possible if the only
entity that can perform dumping is trusted.  Otherwise the whole
thing falls apart really quickly.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
