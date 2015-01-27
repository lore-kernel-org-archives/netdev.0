From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 21:12:20 +1100
Message-ID: <20150127101219.GA3413@gondor.apana.org.au>
References: <20150125232040.GA17936@gondor.apana.org.au>
 <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
 <20150126222259.GC30116@gondor.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD3B6C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Ying Xue <ying.xue@windriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD3B6C@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 27, 2015 at 10:09:18AM +0000, David Laight wrote:
>
> But if err is non-zero you don't hold the mutex.
> Presumably the calling code also errors out immediately,
> so the RCU lock isn't needed at all.

No the calling code expects the RCU lock to be held because it
will always call stop.  Look at how seq_file works.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
