From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 18:23:23 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CCDGd-0003HW-00@gondolin.me.apana.org.au>
References: <4159117A.4010904@us.ibm.com>
Cc: jheffner@psc.edu, davem@davemloft.net, ak@suse.de, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com (Nivedita Singhvi)
In-Reply-To: <4159117A.4010904@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi <niv@us.ibm.com> wrote:
> 
> But I guess my question is - don't we need some
> heuristics to figure out when we should send partial
> (i.e. abandoning waiting for full TSO)?

Currently we're relying on Nagle to do that.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
