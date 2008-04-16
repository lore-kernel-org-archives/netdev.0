From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 23:16:06 +0300
Message-ID: <20080416201606.GS1677@cs181133002.pp.htv.fi>
References: <alpine.DEB.1.10.0804131546370.9318@asgard> <20080414043939.GA6862@1wt.eu> <20080414053943.GU9785@ZenIV.linux.org.uk> <20080413232441.e216a02c.akpm@linux-foundation.org> <20080414072328.GW9785@ZenIV.linux.org.uk> <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au> <4804765B.2070300@davidnewall.com> <bd6139dc0804160515s64a36748v49556c56d475dda4@mail.gmail.com> <20080416132634.GA545@cs181133002.pp.htv.fi> <bd6139dc0804161239h17e79c70ta5e938619e5743c9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: git@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, david@lang.hm,
	Stephen Clark <sclark46@earthlink.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Tilman Schmidt <tilman@imap.cc>,
	Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org, netdev@vger.kernel.org,
	David Newall <davidn@davidnewall.com>
To: sverre@rabbelier.nl
Return-path: <git-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <bd6139dc0804161239h17e79c70ta5e938619e5743c9@mail.gmail.com>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2008 at 09:39:41PM +0200, Sverre Rabbelier wrote:
> On Wed, Apr 16, 2008 at 3:26 PM, Adrian Bunk <bunk@kernel.org> wrote:
>...
> >  E.g. if you look at commit f743d04dcfbeda7439b78802d35305781999aa11
> >  (ide/legacy/q40ide.c: add MODULE_LICENSE), how could you determine
> >  automatically that it is a bugfix, and the commit that introduced
> >  the bug?
> 
> Well, a dead giveaway would be:
> "http://bugzilla.kernel.org/show_bug.cgi?id=10124"

Which could be "There is no driver for my TV card in the kernel."

> >  You can always get some data, but if you want to get usable statistics
> >  you need explicit tags in the commits, not some algorithm that tries
> >  to guess.
> 
> As said above, I don't agree, you can 'guess' very reliably on a large
> dataset. Also, most commits are already 'tagged' in some way or
> another. The trick is to find the pattern in this tagging and use it.
> 
> I hope this clears things up a bit,

I hope you are aware of the non-technical implications if the results 
don't match reality?

E.g. I am proud that my commits do virtually never introduce bugs, so 
any results someone publishes about what I do should better be right
or my first thoughts are somewhere between "fist" and "lawyer". [1]

> Cheers,
> 
> Sverre Rabbelier

cu
Adrian

[1] my actual reaction might only be an angry email, but I hope you
    get the point that wrong results can really piss off people

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
