From: Daniel Barkalow <barkalow@iabervon.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Thu, 15 Nov 2007 11:19:46 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0711151034340.12193__22321.1494311274$1195143718$gmane$org@iabervon.org>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	<20071113.033946.114918709.davem@davemloft.net>
	<20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
	<20071113041259.79c9a8c5.akpm@linux-foundation.org>
	<20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca>
	<40f323d00711130752k19cab8eauc3456721274b3267@mail.gmail.com>
	<20071113171356.GA25824@thunk.org>
	<Pine.LNX.4.64.0711141810110.12193@iabervon.org>
	<20071115153057.GE17180@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-pcmcia@lists.infradead.org, linux-kernel@vger.kernel.org,
	protasnb@gmail.com, linux-ide@vger.kernel.org,
	Benoit Boissinot <bboissin@gmail.com>, Mark Lord <liml@rtr.ca>,
	linux-input@atrey.karlin.mff.cuni.cz,
	Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>
To: Theodore Tso <tytso@mit.edu>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <20071115153057.GE17180@thunk.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007, Theodore Tso wrote:

> On Wed, Nov 14, 2007 at 06:23:34PM -0500, Daniel Barkalow wrote:
> > I don't see any reason that we couldn't have a tool accessible to Ubuntu 
> > users that does a real "git bisect". Git is really good at being scripted 
> > by fancy GUIs. It should be easy enough to have a drop down with all of 
> > the Ubuntu kernel package releases, where the user selects what works and 
> > what doesn't.
> 
> It's possible users who haven't yet downloaded a git repository have
> to surmount some obstacles that might cause them to lose interest.
> First, they have to download some 190 megs of git repository, and if
> they have a slow link, that can take a while, and then they have to
> build each kernel, which can take a while.

It should be possible for it to clone only the portion that they actually 
care about based on where the known-good version is. It should also (in 
theory, anyway) be possible to put off some amount of the download until 
it's actually going to be relevant.

> A full kernel build with everything selected can take good 30 minutes or 
> more, and that's on a fast dual-core machine with 4gigs of memory and 
> 7200rpm disk drives. On a slower, memory limited laptop, doing a single 
> kernel build can take more time than the user has patiences; multiply 
> that by 7 or 8 build and test boots, and it starts to get tiresome.

None of this is going to take as long, even on a slow link and a slow 
computer, as waiting for a response to a mailing list post. It'd annoy 
users who are specifically waiting for it, but if the interface is that 
the user says "kernel package X didn't work but the current kernel does", 
and it says "I'll let you know when I've got something to test", and the 
user watches a DVD, and afterward finds a message saying there's something 
to test, and tries it, and reports how it went, and the process repeats 
until it narrows it down to a single commit after a couple of days of the 
user getting occasional responses, it's not that different from asking for 
help online.

> And then on top of that there are the issues about whether there is
> enough support for dealing with hitting kernel revisions that fail due
> to other bugs getting merged in during the -rc1 process, etc.

Could have a distro-provided mask of things that aren't worth testing and 
possibly back-ported fixes for revisions in particular ranges.

> I agree that a tool that automated the bisection process and walked
> the user through it would be helpful, but I believe it would be
> possible for us do better.

That would probably help for giving the user something to try right away. 
I still think that the main cost to the user is the number of times that 
the user has to stop doing stuff to reboot with a kernel to test, whether 
the test kernels are available quickly from the distro site, slowly built 
locally, or slowly as suggested by humans helping online.

	-Daniel
*This .sig left intentionally blank*
