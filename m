From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] netlink: Mark dumps as inconsistent which have been
 interrupted by a resize
Date: Thu, 22 Jan 2015 20:22:12 +1100
Message-ID: <20150122092212.GA5035@gondor.apana.org.au>
References: <cover.1421759056.git.tgraf@suug.ch>
 <cce004895ab6bcef267e2133a1c7ecab0fac403b.1421759056.git.tgraf@suug.ch>
 <54BF5FC4.4070808@windriver.com>
 <20150121121748.GD12570@casper.infradead.org>
 <20150122084924.GA4720@gondor.apana.org.au>
 <20150122085643.GB4037@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Ying Xue <ying.xue@windriver.com>,
	davem@davemloft.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150122085643.GB4037@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 22, 2015 at 08:56:44AM +0000, Patrick McHardy wrote:
>
> Hope it will still be possible, I need it for GC in timeout support for
> nftables sets.

This should be able to use the same walk that you're currently
using for dump once we add the restart, no?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
