From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6]: Fix policy update bug when increasing priority of
 last policy
Date: Wed, 20 Oct 2004 22:05:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020220558.36427a06.davem@davemloft.net>
References: <E1CJhER-0001vk-00@gondolin.me.apana.org.au>
	<4175238C.7010907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4175238C.7010907@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Oct 2004 16:24:12 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Herbert Xu wrote:
> 
> >Patrick McHardy <kaber@trash.net> wrote:
> >
> >>This patch checks for *p != NULL before continuing the loop.
> >>    
> >>
> >
> >Unfortunately that doesn't fix it completely.  The real bug is
> >the fact that we continue with a bogus p pointing to the deleted
> >element.  So what we should do is continue without updating p
> >at all.
> >  
> >
> You're right, your patch is better. I've tested
> it and it works fine.

I applied Herbert's version of the fix, thanks guys.
