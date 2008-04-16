From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 23:58:29 +0400
Message-ID: <20080416195829.GB4762@martell.zuzino.mipt.ru>
References: <alpine.DEB.1.10.0804131546370.9318@asgard> <20080414043939.GA6862@1wt.eu> <20080414053943.GU9785@ZenIV.linux.org.uk> <20080413232441.e216a02c.akpm@linux-foundation.org> <20080414072328.GW9785@ZenIV.linux.org.uk> <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au> <4804765B.2070300@davidnewall.com> <bd6139dc0804160515s64a36748v49556c56d475dda4@mail.gmail.com> <20080416132634.GA545@cs181133002.pp.htv.fi> <20080416120247.c665859c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@kernel.org>, sverre@rabbelier.nl,
	git@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org, viro@zeniv.linux.org.uk, w@1wt.eu,
	david@lang.hm, sclark46@earthlink.net, johnpol@2ka.mipt.ru,
	rjw@sisk.pl, tilman@imap.cc, Valdis.Kletnieks@vt.edu, lkml@rtr.ca,
	davem@davemloft.net, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org, netdev@vger.kernel.org,
	davidn@davidnewall.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <git-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080416120247.c665859c.akpm@linux-foundation.org>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2008 at 12:02:47PM -0700, Andrew Morton wrote:
> On Wed, 16 Apr 2008 16:26:34 +0300
> Adrian Bunk <bunk@kernel.org> wrote:
> 
> > On Wed, Apr 16, 2008 at 02:15:22PM +0200, Sverre Rabbelier wrote:
> > > I'm not subscribed to the kernel mailing list, so please include me in
> > > the cc if you don't reply to the git list (which I am subscribed to).
> > > 
> > > Git is participating in Google Summer of Code this year and I've
> > > proposed to write a 'git statistics' command. This command would allow
> > > the user to gather data about a repository, ranging from "how active
> > > is dev x" to "what did x work on in the last 3 weeks".

These are pointy-hairy questions.

> > > It's main
> > > feature however, would be an algorithm that ranks commits as being
> > > either 'buggy', 'bugfix' or 'enhancement'. (There are several clues
> > > that can aid in determining this, a commit msg along the lines of
> > > "fixes ..." being the most obvious.)
> > >...
> 
> Sounds like an interesting project.

The interesting (and answerable) questions are:

1) How many bugs one non-merge commit brings on average
2) What is average time between buggy commit entering Linus's tree and
   fix entering the same tree.
3) Graphs of #1 and #2 over time.
4) rough division of bugs a-la refcounting, locking, hw, hw workaround.
5) if other OS have such statistics, comparison with them
   (little finger for this)

#1 alone can shred OSDL and LWN induced PDFs into innumerable pieces!
