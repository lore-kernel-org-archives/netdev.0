From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RTNETLINK] Provide real oif
Date: Wed, 03 Dec 2003 07:54:17 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1ARHXF-0007cM-00@gondolin.me.apana.org.au>
References: <1070368316.1031.30.camel@jzny.localdomain>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, netdev@oss.sgi.com
In-Reply-To: <1070368316.1031.30.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> wrote:
> 
> Can you provide a real example (output of route display in user space)
> where this would be valuable?

Without the real oif you will see entries like this in the output of
ip r l c:

192.168.0.7 dev eth0  src 192.168.0.6
    cache  mtu 1500 advmss 1460 metric10 64
192.168.0.7 dev eth0  src 192.168.0.6
    cache  mtu 1500 advmss 1460 metric10 64

One of those has oif == 0 while the other one has oif == eth0.

To generate an entry with oif == eth0, just send a UDP packet and
bound to eth0.

> whats wrong with the combo of RTA_OIF and RTA_SRC?

Both of those attributes are independent of the real oif.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
