From: Theodore Tso <tytso@mit.edu>
Subject: Re: [BUG] New Kernel Bugs
Date: Thu, 15 Nov 2007 10:30:57 -0500
Message-ID: <20071115153057.GE17180@thunk.org>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <40f323d00711130752k19cab8eauc3456721274b3267@mail.gmail.com> <20071113171356.GA25824@thunk.org> <Pine.LNX.4.64.0711141810110.12193@iabervon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benoit Boissinot <bboissin@gmail.com>, Mark Lord <liml@rtr.ca>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Daniel Barkalow <barkalow@iabervon.org>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711141810110.12193@iabervon.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 06:23:34PM -0500, Daniel Barkalow wrote:
> I don't see any reason that we couldn't have a tool accessible to Ubuntu 
> users that does a real "git bisect". Git is really good at being scripted 
> by fancy GUIs. It should be easy enough to have a drop down with all of 
> the Ubuntu kernel package releases, where the user selects what works and 
> what doesn't.

It's possible users who haven't yet downloaded a git repository have
to surmount some obstacles that might cause them to lose interest.
First, they have to download some 190 megs of git repository, and if
they have a slow link, that can take a while, and then they have to
build each kernel, which can take a while.  A full kernel build with
everything selected can take good 30 minutes or more, and that's on a
fast dual-core machine with 4gigs of memory and 7200rpm disk drives.
On a slower, memory limited laptop, doing a single kernel build can
take more time than the user has patiences; multiply that by 7 or 8
build and test boots, and it starts to get tiresome.  

And then on top of that there are the issues about whether there is
enough support for dealing with hitting kernel revisions that fail due
to other bugs getting merged in during the -rc1 process, etc.

I agree that a tool that automated the bisection process and walked
the user through it would be helpful, but I believe it would be
possible for us do better.

						- Ted
