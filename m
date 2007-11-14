From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 18:10:34 -0800
Message-ID: <20071113181034.4ed733fa.akpm@linux-foundation.org>
References: <20071113134029.GA30978@elte.hu>
	<4739AFE0.20705@rtr.ca>
	<20071113164650.GA28493@elte.hu>
	<4739E3D0.10201@rtr.ca>
	<20071113181228.GF4250@stusta.de>
	<4739EA83.5040006@rtr.ca>
	<20071113183605.GG4250@stusta.de>
	<4739F12E.5020807@rtr.ca>
	<20071113190428.GH4250@stusta.de>
	<4739FA4D.1050900@rtr.ca>
	<20071113200028.GJ4250@stusta.de>
	<20071113211256.1d18fe1a@the-village.bc.nu>
	<473A46C1.3060000@redhat.com>
	<20071113171136.75ba098d@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
        Adrian Bunk <bunk@kernel.org>, Mark Lord <liml@rtr.ca>,
        Ingo Molnar
 <mingo@elte.hu>, David Miller <davem@davemloft.net>,
        protasnb@gmail.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, alsa-devel@alsa-project.org,
        linux-ide@vger.kernel.org, linux-pcmcia@lists.infradead.org,
        linux-input@atrey.karlin.mff.cuni.cz, bugme-daemon@bugzilla.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113171136.75ba098d@freepuppy.rosehill>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007 17:11:36 -0800 Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> On Tue, 13 Nov 2007 19:52:17 -0500
> Chuck Ebbert <cebbert@redhat.com> wrote:
> 
> > On 11/13/2007 04:12 PM, Alan Cox wrote:
> > >> Bug fixing is not about finding someone to blame, it's about getting the 
> > >> bug fixed.
> > > 
> > > Partly - its also about understanding why the bug occurred and making it
> > > not happen again.
> > 
> > Very few people think about that part.
> 
> Why does the kernel have very few useful tests?

Tests would of course be nice, but they aren't very useful(!)

Looking at this list which Natalie has generated I see around thirty which
are dependent on the right hardware and ten which are not.  This ratio is
typical, I think.  In fact I'd say that more than 75% of reported bugs are
dependent on hardware.

So the best test of all for the kernel is "run it on a different machine". 
This is why we are sooooo dependent upon our volunteer testers/reporters to
be able to do kernel development.

>  Lack of interest? resources? expertise?
> Ideally each new feature would just be a small add on to an existing test.

Sure.  For system-call-visible features it would be good to do that.

But this tends not to be where bugs get exposed.  Because the original
developer can 100% exercise such code.  That isn't the case with
driver/arch/platform changes.

> Unlike developing new features which seems to grow well with more developers.
> Bug fixing also seems to be a scarcity process. There often seems to be
> a very few people that understand the problem well enough or have the necessary
> hardware to reproduce and fix the problem.

We're 100% dead if "having the hardware" is a prerequisite to fixing a bug.
The terminal state there is that the kernel runs on about 200 machines
worldwide.  We have to work with reporters via email to fix these sorts of
things.  As we of course do.

> Recent changes like tickless and scheduler rework were well thought out and caused
> very little impact to 90% of the users. The problem is the 10% who do have problems.
> Worse, the developers often only hear about the a small sample of those.

Yes.  An unknown number of people just shrug and go back to an old kernel.
