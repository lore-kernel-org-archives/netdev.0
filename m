From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6]: Check against correct policy list in ip_forward/ip6_forward
Date: Mon, 18 Oct 2004 07:23:17 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041017212317.GA28615@gondor.apana.org.au>
References: <4172943B.8050904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4172943B.8050904@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 17, 2004 at 05:48:11PM +0200, Patrick McHardy wrote:
> 
> currently forwarded packets from a tunnel mode SA are checked
> in ip_forward/ip6_forward against the XFRM_POLICY_FWD policy
> list. Neither racoon nor pluto generate a policy for
> IPSEC_DIR_FWD, so the checks are performed against an empty

Actually I made damn sure that pluto does generate rules for
IPSEC_DIR_FWD after discussing it with Alexey :) Search for
XFRM_POLICY_FWD in openswan/programs/pluto.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
