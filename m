From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Allow transport SAs even when there is no policy
Date: Wed, 20 Oct 2004 07:25:29 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019212529.GA16127@gondor.apana.org.au>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au> <4172F1AB.4020305@trash.net> <20041017231258.GA29294@gondor.apana.org.au> <417428CF.2050802@trash.net> <20041018214326.GA6589@gondor.apana.org.au> <417521A2.4010500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <417521A2.4010500@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2004 at 04:16:02PM +0200, Patrick McHardy wrote:
>
> Looks good. So you agree we should also apply my patch to
> xfrm_policy_lookup (attached again with less confusing subject) ? It makes
> packets with a secpath fall through to __xfrm_policy_check when the policy
> list is empty, so the default policy is always the same. This will break
> setups with keying daemons that don't add forward policies for tunnel mode
> SAs.

Agreed.  Thanks.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
