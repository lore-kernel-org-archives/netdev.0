From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Mon, 1 Dec 2003 13:51:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201135154.6906454c.davem@redhat.com>
References: <20031201201651.GA20194@gondor.apana.org.au>
	<20031201204700.GA20349@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031201204700.GA20349@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Dec 2003 07:47:00 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Dec 02, 2003 at 07:16:51AM +1100, herbert wrote:
> > 
> > I found out that PMTU only works on those routing cache entries where
> > rt_src != 0.  This patch should make it work for all matching entries.
> 
> That patch removed one line too many.  This one should be better.

Hmmm... 

Herbert, do you see how the outer loop and the skey[] thing works in
this PMTU handling code?  This takes care of comparing both iph->saddr
and '0' against rt->rt_src.
