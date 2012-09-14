From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: Allow xt_nat.c and x_tables.c to compiled in
Date: Fri, 14 Sep 2012 14:25:14 +0200
Message-ID: <1347625514.26523.2.camel@edumazet-glaptop>
References: <87627hfi69.fsf@xmission.com>
	 <Pine.GSO.4.63.1209141353470.11622@stinky-local.trash.net>
	 <20120914120853.GA6056@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@gnumonks.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120914120853.GA6056@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-09-14 at 14:08 +0200, Pablo Neira Ayuso wrote:
> On Fri, Sep 14, 2012 at 01:54:22PM +0200, Patrick McHardy wrote:
> > On Thu, 13 Sep 2012, Eric W. Biederman wrote:
> > 
> > >xt_init in x_tables.c must be called before xt_nat_init in xt_nat.c
> > >Reorder the makefile so that x_tables.o comes before xt_nat.o in
> > >netfilter.o.
> > >
> > >This allows me to built a kernel with both of these modules compiled in.
> > 
> > Thanks, we've already fixed that, the patch is queued in Pablo's tree.
> 
> It should hit Linus tree soon, David pulled the fix yesterday.
> --

Little correction :

Its in net-next, Linus tree doesnt need this fix yet.

http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commitdiff;h=00545bec9412d130c77f72a08d6c8b6ad21d4a1e



