From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 3796] New: ipsec causes kernel deadlock
Date: Tue, 23 Nov 2004 07:37:36 +1100
Message-ID: <E1CWKwK-0008CM-00@gondolin.me.apana.org.au>
References: <20041122115935.4d6f4e21.akpm@osdl.org>
Cc: netdev@oss.sgi.com, bill@crowellsystems.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20041122115935.4d6f4e21.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> Problem Description: when instantiating a gateway-network connection using
> Openswan tools, the server at the 'gateway' end of the tunnel connection will
> deadlock during the ISAKMP stage 1. The network-network tunnel is built

ISAKMP stage does not involve the kernel IPsec stack so the bug is
probably elsewhere.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
