From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM] Allow transport SAs even when there is no policy
Date: Wed, 20 Oct 2004 22:02:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020220255.0d2c6014.davem@davemloft.net>
References: <4172943B.8050904@trash.net>
	<20041017212317.GA28615@gondor.apana.org.au>
	<4172F1AB.4020305@trash.net>
	<20041017231258.GA29294@gondor.apana.org.au>
	<417428CF.2050802@trash.net>
	<20041018214326.GA6589@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@redhat.com, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041018214326.GA6589@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Oct 2004 07:43:26 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Oct 18, 2004 at 10:34:23PM +0200, Patrick McHardy wrote:
> > 
> > > More importantly that it'll stick out like a sore thumb in terms of
> > >
> > > its semantics.
> > 
> > __xfrm_policy_check already rejects packets without a matching policy
> > and skb->sp set, but it is skipped while the policy list is empty.
> > What, from a semantics point of view, would be wrong with making
> > xfrm_policy_check behave the same way ?
> 
> Good catch.  That was a bug introduced by yours truly :)
> 
> What I meant to say is all packets with tunnel mode SAs should be
> rejected since we don't allow optional tunnel transforms for security
> reasons.
> 
> This patch fixes it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
