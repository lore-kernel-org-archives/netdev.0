From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM] Allow transport SAs even when there is no policy
Date: Wed, 20 Oct 2004 22:04:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020220417.58f9ccb2.davem@davemloft.net>
References: <4172943B.8050904@trash.net>
	<20041017212317.GA28615@gondor.apana.org.au>
	<4172F1AB.4020305@trash.net>
	<20041017231258.GA29294@gondor.apana.org.au>
	<417428CF.2050802@trash.net>
	<20041018214326.GA6589@gondor.apana.org.au>
	<417521A2.4010500@trash.net>
	<20041019212529.GA16127@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@redhat.com, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041019212529.GA16127@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Oct 2004 07:25:29 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Oct 19, 2004 at 04:16:02PM +0200, Patrick McHardy wrote:
> >
> > Looks good. So you agree we should also apply my patch to
> > xfrm_policy_lookup (attached again with less confusing subject) ? It makes
> > packets with a secpath fall through to __xfrm_policy_check when the policy
> > list is empty, so the default policy is always the same. This will break
> > setups with keying daemons that don't add forward policies for tunnel mode
> > SAs.
> 
> Agreed.  Thanks.

Also applied.  Thanks Patrick and Herbert.

BTW, Herbert, you can use a signed-off-by: line as an "ACK"
if you want :-)
