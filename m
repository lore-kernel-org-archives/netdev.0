From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Wed, 06 Apr 2005 12:19:12 +1000
Message-ID: <E1DJ08O-0003Ln-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.58.0504051507250.17203@server.graphe.net>
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: christoph@lameter.com (Christoph Lameter)
In-Reply-To: <Pine.LNX.4.58.0504051507250.17203@server.graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@lameter.com> wrote:
> 
> If that is so then it is also possible that the gc frees after
> atomic_dec_and_test:

No this is prevented by the nohash check.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
