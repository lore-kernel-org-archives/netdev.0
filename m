From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Fri, 24 Sep 2004 09:41:04 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CAdCy-0001FM-00@gondolin.me.apana.org.au>
References: <20040923161141.4ea9be4c.davem@davemloft.net>
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20040923161141.4ea9be4c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> That means as the window fills up, we have to see 44 ACKs
> before we are able to send the next TSO frame.  Needless to
> say that breaks ACK clocking completely.

Hang on a second, the same problem would occur before the congestion
changes were made, right? I thought Anton was saying that with the
old kernels he was getting 100MB/s with TSO enabled...

Anton, can you please get tcpdump to somehow show the length of the
TSO packets so that we know what the factor is being set to?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
