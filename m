From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: net/sctp/sm_make_chunk.c alignment problems on parisc64
Date: Thu, 25 Sep 2003 17:52:38 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925205238.GB1041@conectiva.com.br>
References: <20030920155404.GA29040@conectiva.com.br> <Pine.LNX.4.44.0309221441070.5222-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0309221441070.5222-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Sep 22, 2003 at 03:06:41PM -0700, Sridhar Samudrala escreveu:
> On Sat, 20 Sep 2003, Arnaldo Carvalho de Melo wrote:
> > The problem is right at:
> > 
> > tv_add(&asoc->cookie_life, &cookie->c.expiration);
> > 
> > Please send any patch you come up with, I'll be happy to test it.
> 
> The problem seems to be the static inline routine tv_add. When i converted it
> into a regular function or a macro, the problem went away. May be parisc64
> compiler has some issues with static inlines.
> 
> Arnaldo, Could you please try out this patch which converts tv_add() to a macro
> TIMEVAL_ADD()

Yes, this makes the problem go away, if you have this tested please push it
DaveM's way, thanks a lot!

- Arnaldo
