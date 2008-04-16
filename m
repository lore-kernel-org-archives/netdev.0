From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 16:26:34 +0300
Message-ID: <20080416132634.GA545@cs181133002.pp.htv.fi>
References: <20080413205406.GA9190@2ka.mipt.ru> <48028830.6020703@earthlink.net> <alpine.DEB.1.10.0804131546370.9318@asgard> <20080414043939.GA6862@1wt.eu> <20080414053943.GU9785@ZenIV.linux.org.uk> <20080413232441.e216a02c.akpm@linux-foundation.org> <20080414072328.GW9785@ZenIV.linux.org.uk> <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au> <4804765B.2070300@davidnewall.com> <bd6139dc0804160515s64a36748v49556c56d475dda4@mail.gmail.com>
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
In-Reply-To: <bd6139dc0804160515s64a36748v49556c56d475dda4@mail.gmail.com>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2008 at 02:15:22PM +0200, Sverre Rabbelier wrote:
> I'm not subscribed to the kernel mailing list, so please include me in
> the cc if you don't reply to the git list (which I am subscribed to).
> 
> Git is participating in Google Summer of Code this year and I've
> proposed to write a 'git statistics' command. This command would allow
> the user to gather data about a repository, ranging from "how active
> is dev x" to "what did x work on in the last 3 weeks". It's main
> feature however, would be an algorithm that ranks commits as being
> either 'buggy', 'bugfix' or 'enhancement'. (There are several clues
> that can aid in determining this, a commit msg along the lines of
> "fixes ..." being the most obvious.)
>...

At least with the data we have currently in git it's impossible to 
figure that out automatically.

E.g. if you look at commit f743d04dcfbeda7439b78802d35305781999aa11 
(ide/legacy/q40ide.c: add MODULE_LICENSE), how could you determine 
automatically that it is a bugfix, and the commit that introduced
the bug?

You can always get some data, but if you want to get usable statistics 
you need explicit tags in the commits, not some algorithm that tries 
to guess.

> Cheers,
> 
> Sverre Rabbelier

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
