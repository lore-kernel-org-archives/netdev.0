From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: (udp-en/decap broken in 2.6.8-rc2?) Re: ipsec, nat-t, iproute2?
Date: Sat, 31 Jul 2004 17:50:05 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1Bqod3-0004FB-00@gondolin.me.apana.org.au>
References: <20040730223808.GA12660@outpost.ds9a.nl>
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20040730223808.GA12660@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert <ahu@ds9a.nl> wrote:
> 
> The encoding looks fine but the receiving side does not appear to listen:
> 
> 00:34:09.491228 IP 192.168.1.4.4500 > 10.0.0.3.4500: UDP, length: 88
> 00:34:09.492290 IP 10.0.0.3 > 192.168.1.4: icmp 124: 10.0.0.3 udp port 4500
>        unreachable

You need to have someone open a socket on port 4500 and do the
appropriate setsockopt() on it.
 
> This is the setkey configuration I use on 10.0.0.3:

Any reason why you aren't using automatic keying?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
