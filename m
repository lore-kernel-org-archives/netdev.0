From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Trivial fix for out of bounds array access in
 xfrm4_policy_check
Date: Tue, 7 Sep 2004 14:02:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907140245.675b7240.davem@davemloft.net>
References: <Pine.LNX.4.61.0409071322100.8637@hosting.rdsbv.ro>
	<E1C4fMc-000817-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: util@deuroconsult.ro, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C4fMc-000817-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 07 Sep 2004 22:46:22 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Catalinux aka Dino BOIE <util@deuroconsult.ro> wrote:
> > 
> > Coverity found a bug in accessing xfrm4_policy_check using XFRM_POLICY_FWD 
> > (=2) as index in sk->sk_policy.
> > 
> > sk->sk_policy[] is defined in sock.h as:
> > 
> > struct xfrm_policy *sk_policy[2];
> > 
> > Attached is the fix.
> 
> This is bogus as if the packet is forwarded then sk == NULL.

Agreed.
