From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC PATCH] missing break in UDP decap code Re: (udp-en/decap broken in 2.6.8-rc2?) Re: ipsec, nat-t, iproute2?
Date: Sun, 1 Aug 2004 05:32:04 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731193204.GA20793@gondor.apana.org.au>
References: <20040731083456.GA24761@outpost.ds9a.nl> <E1Bqr9r-0004av-00@gondolin.me.apana.org.au> <20040731112048.GA27893@outpost.ds9a.nl> <20040731115230.GA18537@gondor.apana.org.au> <20040731121828.GA29497@outpost.ds9a.nl> <20040731130853.GA30481@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com, davem@redhat.com
Content-Disposition: inline
In-Reply-To: <20040731130853.GA30481@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 31, 2004 at 03:08:53PM +0200, bert hubert wrote:
> 
> Against 2.6.8-rc2, neatly solves the problem. The missing break causes the
> packet to be tested against both encapsulation types, one will always fail.

Sorry, that was my fault.

Dave, please apply his patch to fix NON_ESP reception.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
