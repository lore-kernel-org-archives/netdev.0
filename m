From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Fri, 5 Dec 2014 00:10:58 +0800
Message-ID: <20141204161058.GA22431@gondor.apana.org.au>
References: <20141204081147.GA19030@gondor.apana.org.au>
 <20141204152637.GA32140@casper.infradead.org>
 <20141204152929.GA22075@gondor.apana.org.au>
 <20141204153938.GC32140@casper.infradead.org>
 <54808123.8000704@redhat.com>
 <20141204154708.GA22185@gondor.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CA0284A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Theodore Ts'o <tytso@mit.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA0284A@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 04, 2014 at 03:56:30PM +0000, David Laight wrote:
> 
> "This CRC algorithm used by this hash is 'linear', ie hash(a xor b) ==
> hash(a) xor hash(b). This means that it is relatively easy for a remote
> attacker to generate multiple items with the same hash."

The attacker could be local too, e.g., opening a netlink socket
can be done by any user and gets hashed in net/netlink/af_netlink.c.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
