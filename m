From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/05: netfilter fixes
Date: Mon, 09 Feb 2009 15:18:06 -0800 (PST)
Message-ID: <20090209.151806.02424601.davem@davemloft.net>
References: <20090209163926.13918.96177.sendpatchset@x2.localnet>
	<20090209.143238.25276576.davem@davemloft.net>
	<4990B26B.3020705@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4990B26B.3020705@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 09 Feb 2009 23:47:07 +0100

> David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Mon,  9 Feb 2009 17:39:27 +0100 (MET)
> > 
> >> Please apply or pull from:
> >>
> >> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git
> > I was going to pull from your tree and take it like that, but when I
> > pulled I got 5 real changes and 50 merges with net-2.6, yikes! :-)
> 
> Ugh sorry, thats happening automatically, but it usually doesn't show
> up since it should be fast forwards. I'll have a look at what went
> wrong.

I think you got a change into your tree locally, this went via net-2.6
and thereafterwards it started using merges.  But that's just a guess.

> > If there was one or two merge changesets in there, I would have
> > taken it.  But anything more than that for a tree containing
> > 5 bug fixes is excessive.
> > I'll apply these as patches, but I really do want to be able to
> > pull from your trees so please try to provide a cleaner tree
> > next time.
> 
> I'll make sure of it, sorry.

Want some suggestions for work flow? :-)

1) For net-2.6 just clone Linus's tree, pull net-2.6 once as it is
   right now, then leave it alone.

   Periodically sync your origin (which is Linus's tree) via
   "git fetch origin".  This just grabs the objects.

   Then you can just go "git request-pull origin $(GIT_URL)" and
   it'll just work.

   Since the likelyhood for conflicts in the net-2.6 tree with
   your netfilter work is incredibly unlikely, doing a merge
   should never be necessary.  But if it is just go
   "git pull origin".

2) For net-next-2.6 use net-next-2.6 as your "origin" (you can change
   this in .git/config), conflicts are more likely so every once in
   a while a "git pull origin" will be necessary.

If that doesn't work out or feel comfortable for you, that's
fine.
