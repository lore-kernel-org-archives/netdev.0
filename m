From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [E1000-devel] [PATCH] e1000: Allow the driver to be used on PA
	RISC C8000 workstation
Date: Sat, 2 Jul 2011 18:33:36 -0600
Message-ID: <20110703003336.GC20434@parisc-linux.org>
References: <A78C6259B11833419567082E2DC0C25601D8A9CA5E@orsmsx508.amr.corp.intel.com> <1538517.jd8kKEpd3f@donald.sf-tec.de> <2567734.3Tpd1BeV4a@donald.sf-tec.de> <1793556.1X3EUabhs6@donald.sf-tec.de> <BANLkTimbhOpp624KKU0dEE63mkAC1SDMAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Guy Martin <gmsoft@tuxicoman.be>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"mikulas@artax.karlin.mff.cuni.cz" <mikulas@artax.karlin.mff.cuni.cz>,
	netdev@vger.kernel.org
To: Matt Turner <mattst88@gmail.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTimbhOpp624KKU0dEE63mkAC1SDMAg@mail.gmail.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 27, 2011 at 03:33:43PM -0400, Matt Turner wrote:
> On Mon, Jun 27, 2011 at 2:42 PM, Rolf Eike Beer <eike-kernel@sf-tec.de> wrote:
> > Rolf Eike Beer wrote:
> >> Am Freitag, 18. M?rz 2011, 17:39:57 schrieb Rolf Eike Beer:
> >> > Am Mittwoch, 2. M?rz 2011, 21:19:24 schrieb Jesse Brandeburg:
> >> > > On Mon, Feb 28, 2011 at 5:40 AM, Guy Martin <gmsoft@tuxicoman.be> wrote:
> >> > > > Hi Jeff,
> >> > > >
> >> > > > Any luck getting this into mainline ?
> >> > >
> >> > > Hi Guy, sorry for the delay,
> >> > > We haven't been able to get our contacts in HP to give us a decent
> >> > > response so far, we are following up with them to see whats up. ?We
> >> > > have not lost the patch and are still tracking it internally.
> >> > >
> >> > > Give us a couple more weeks if that is okay and we should be able to
> >> > > settle this by then.
> >> >
> >> > I wonder what exactly you are waiting for? This is a sanity check that
> >> > we
> >> > disable, so no working systems could get broken by this. And every
> >> > single
> >> > C8000 seems to be affected by this and is working fine with that patch.
> >> > So maybe people at HP might have a clue _why_ this is screwed, but
> >> > until then I don't see any point in waiting.
> >> >
> >> > So please just add my tested-by and push this upstream soon. Since this
> >> > is basically a hardware quirk I would like to get this into stable also
> >> > so we may run vanilla 2.6.38.1 or something like that on C8000.
> >> >
> >> > Tested-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
> >>
> >> For the netdev folks: it's this patch we are talking about
> >>
> >> http://www.spinics.net/lists/linux-parisc/msg03091.html
> >>
> >> I would love to see that someone finally picks this up and pushes this
> >> upstream, CC stable. This is absolutely annoying as it breaks every time
> >> anyone touches the kernel on one of this machines.
> >>
> >> Jeff, David, James: can you please make a decision of who takes this and
> >> then just do it?
> >
> > Ping?
> 
> Ping indeed. Waiting as if HP is going to say "yes, we fucked that up.
> Go ahead with the patch." is silly.

AFAIK, HP hasn't paid anyone to work on parisc-linux in almost 10 years.
Good luck finding someone in HP who knows about C8000, much less it's
NIC firmware.

Jesse or Jeff K. should be able to accept the patch as-is.
I don't see any problem with it.

hth,
grant (ex-HP employee: 1999-2002 parisc-linux and 2002-2006 ia64-linux drivers)
