From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: Re: [0/3] Fix timer bugs in neighbour cache
Date: Sun, 23 Oct 2005 14:16:18 -0200
Message-ID: <20051023161617.GB26530@mandriva.com>
References: <43534273.2050106@reub.net> <E1ETaJB-0004a0-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Reuben Farrelly <reuben-lkml@reub.net>, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, greearb@candelatech.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750756AbVJWQQe@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1ETaJB-0004a0-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Sun, Oct 23, 2005 at 05:30:21PM +1000, Herbert Xu escreveu:
> Reuben Farrelly <reuben-lkml@reub.net> wrote:
> > 
> > Oct 17 18:49:40 tornado kernel: NEIGH: BUG, double timer add, state is 1
> > Oct 17 18:51:04 tornado last message repeated 3 times
> > Oct 17 18:52:05 tornado last message repeated 5 times
> > Oct 17 18:52:11 tornado last message repeated 2 times
> 
> Excellent.  Looks like we actually caught something.  Pity we don't have
> a stack trace which means that there might be more bugs.
> 
> Anyway, here are three patches which should fix this.  This should go
> into 2.6.14.
> 
> Arnaldo, you can pull them from
> 
> master.kernel.org:/pub/scm/linux/kernel/git/herbert/net-2.6.git

Thanks, pulled.

I guess at some point I'll try to make the neighbour code more like the
sock one where we have things like sk_reset_timer and sk_stop_timer for
this purpose.

- Arnaldo
