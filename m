From: Willy Tarreau <w@1wt.eu>
Subject: Re: size of git repository (was Re: [BUG] New Kernel Bugs)
Date: Mon, 19 Nov 2007 05:43:13 +0100
Message-ID: <20071119044313.GC15227@1wt.eu>
References: <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071118124404.GA4037@ucw.cz> <20071118145611.GB22622@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@ucw.cz>, Mark Lord <liml@rtr.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2386 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbXKSEoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Nov 2007 23:44:11 -0500
Content-Disposition: inline
In-Reply-To: <20071118145611.GB22622@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 18, 2007 at 03:56:11PM +0100, Ingo Molnar wrote:
> 
> * Pavel Machek <pavel@ucw.cz> wrote:
> 
> > On Tue 2007-11-13 12:50:08, Mark Lord wrote:
> > > Ingo Molnar wrote:
> > > >
> > > >for example git-bisect was godsent. I remember that 
> > > >years ago bisection of a bug was a very laborous task 
> > > >so that it was only used as a final, last-ditch 
> > > >approach for really nasty bugs. Today we can 
> > > >autonomouly bisect build bugs via a simple shell 
> > > >command around "git-bisect run", without any human 
> > > >interaction! This freed up testing resources 
> > > ..
> > > 
> > > It's only a godsend for the few people who happen to be 
> > > kernel developers
> > > and who happen to already use git.
> > > 
> > > It's a 540MByte download over a slow link for everyone 
> > > else.
> > 
> > Hmmm, clean-cg is 7.7G on my machine, and yes I tried 
> > git-prune-packed. What am I doing wrong?
> 
> "git-repack -a -d" gives me ~220 MB:
> 
>   $ du -s .git
>   222064  .git
> 
> anyone who can download a 43 MB tar.bz2 tarball for a kernel release 
> should be able to afford a _one time_ download size of 250 MB (the size 
> of the current kernel.org git repository). If not, burning a CD or DVD 
> and carrying it home ought to do the trick. Git is very 
> bandwidth-efficient after that point - lots of people behind narrow 
> pipes are using it - it's just the initial clone that takes time. And 
> given all the history and metadata that the git repository carries (full 
> changelogs, annotations, etc.) it's a no-brainer that kernel developers 
> should be using it.
> 
> (and you can shrink the 250 MB further down by using shallow clones, 
> etc.)
> 
> yes, some people complained when distros stopped doing floppy installs. 
> Some people complained when distros stopped doing CD installs. Yes, i've 
> myself done a 250+ MB download over a 56 kbit modem in the past, and 
> while it indeed took overnight to finish, it's very much doable. It's 
> not really qualitatively different from the 1.5 hours a kernel tar.bz2 
> took to download.

Probably that once in a while, we should set up a complete tree in a
tar.bz2 format on kernel.org. It would help a lot of people behind small
pipes. I have been encountering problems with git-clone when the link is
unstable. After the smallest error, it erases everything and you have to
retry from start, which is quite frustrating and expensive.

At least, downloading a tar.bz2 with FTP would be easier and a lot more
reliable. Also, people could download it from their workplace and bring
it home.

Willy

