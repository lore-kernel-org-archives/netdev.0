From: "David S. Miller" <davem@davemloft.net>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Tue, 5 Apr 2005 14:48:53 -0700
Message-ID: <20050405144853.0523fde6.davem@davemloft.net>
References: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>
	<E1DIvr8-0002yy-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: christoph@lameter.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DIvr8-0002yy-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 06 Apr 2005 07:45:06 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> When we are not the real parent of the dst (e.g., when we're xfrm_dst
> and the child is an rtentry), it may already be on the GC list.
> 
> In fact the current code is buggy to, we need to check dst->flags
> before the dec as dst may no longer be valid afterwards.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Good catch Herbert, I'll apply this.
