From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: IPsec and Path MTU
Date: Tue, 15 Jun 2004 22:43:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615124334.GA25164@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi:

Can someone explain the rationale behind dst->path and dst_pmtu to me?

As far as I can see it was introduced specifically for IPsec.  However,
it seems to me that it makes no sense whatsoever in that case.

As it is, the MTU for any peer with an IPsec policy is determined
by the MTU of its dst->path.  But this is wrong because it assigns
a single MTU to all hosts behind an IPsec gateway, even though their
paths may well diverge beyond the gateway.

So unless I'm missing something, we should get rid of dst->path and
store the MTU in the xfrm dst's directly.

Comments?
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
