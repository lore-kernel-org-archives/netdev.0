From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Minor IPSec bug + solution
Date: Fri, 17 Sep 2004 07:19:23 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C83f1-0002X7-00@gondolin.me.apana.org.au>
References: <1095327372.4466.87.camel@mabouzek>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: martin.bouzek@radas-atc.cz
In-Reply-To: <1095327372.4466.87.camel@mabouzek>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin Bouzek <martin.bouzek@radas-atc.cz> wrote:
> 
> I was setting up an VPN via IPSec in kernel 2.6.x on IPv4 and found the
> following bug. It is not possible to set up an IPComp/ESP tunnel with
> IPComp set as mandatory. The following setup works fine for me:

You can never set IPComp as mandatory because ipcomp_output() will not
compress anything that is incompressible.

> function. For tunnels it returns 
> 
> tmpl->optional && !xfrm_state_addr_cmp(tmpl, x, family);

The check is correct as it is.  Internal states must never match any
required transform.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
