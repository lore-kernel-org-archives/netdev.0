From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4180] New: masquarade and source ip
Date: Tue, 08 Feb 2005 07:35:22 +1100
Message-ID: <E1CyFbO-0005cI-00@gondolin.me.apana.org.au>
References: <20050207111822.65038881.akpm@osdl.org>
Cc: netdev@oss.sgi.com
To: spied@yandex.ru
In-Reply-To: <20050207111822.65038881.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> ip addr add eth0 1.2.3.4
> ip addr add eth0 2.3.4.5

Unless you put netmasks on the addresses, e.g., 2.3.4.5/30, the kernel
won't know that 2.3.4.5 is a better address to use than 1.2.3.4 when
trying to reach 2.3.4.6.

> ip route add default via 2.3.4.6 src 2.3.4.5

This src setting does not survive through to the MASQUERADE target and
therefore has no effect.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
