From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] (1/3) tcp - choose congestion algorithm at initialization
Date: Tue, 28 Sep 2004 08:07:36 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CC3ei-00020G-00@gondolin.me.apana.org.au>
References: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
> The choice of congestion algorithm needs to be made when connection
> is setup to avoid problems when the sysctl values change later and the
> necessary data hasn't been collected.

Could this be chosen by a setsockopt as well?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
