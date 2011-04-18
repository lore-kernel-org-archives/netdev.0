From: Micha? Miros?aw <mirq-linux@rere.qmqm.pl>
Subject: Re: Driver build-testing (was: [PATCH] net: dm9000: Fix build)
Date: Mon, 18 Apr 2011 17:17:29 +0200
Message-ID: <20110418151729.GA4721@rere.qmqm.pl>
References: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com> <20110418111203.GB18324@rere.qmqm.pl> <20110418122522.GC9462@sirena.org.uk> <20110418145102.GA2555@rere.qmqm.pl> <20110418075508.f7b14f43.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>,
	netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59573 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751753Ab1DRPRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 11:17:30 -0400
Content-Disposition: inline
In-Reply-To: <20110418075508.f7b14f43.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 07:55:08AM -0700, Randy Dunlap wrote:
> On Mon, 18 Apr 2011 16:51:02 +0200 Micha? Miros?aw wrote:
>=20
> > On Mon, Apr 18, 2011 at 01:25:22PM +0100, Mark Brown wrote:
> > > On Mon, Apr 18, 2011 at 01:12:03PM +0200, Micha? Miros?aw wrote:
> > > > This brings the issue of build testing effectiveness. In curren=
t code
> > > > there is no configuration that makes all drivers build. I would=
 like
> > > > to see something like 'make brokenconfig' that would allow most=
 of
> > > > the code to be built, and not necessarily working. Maybe someon=
e has
> > > > an idea how to implement that?
> > > For the drivers that genuinely are rather platform specific this =
tends
> > > to fail very badly as you need headers that only come along with =
the
> > > architecture.
> > >=20
> > > In the case of DM9000 if it fails to build on your platform then =
the
> > > driver is just buggy - looking at the Kconfig I rather suspect th=
at the
> > > dependency on architectures should just be removed.
> > I wonder if allyesconfig/allmodconfig is supposed to include code t=
hat's
> > known not to work for a particular architecture.
> all*config just use whatever is in all of the various Kconfig* files.
> If they say "depends on $somearch", then so be it.  If not, then the
> remaining dependencies are used.

Yes, I know how it works. I just wonder if removing those dependencies =
so
that all drivers (even if known not to work) are built on all*config
is acceptable. Or maybe there should be a config like 'disable all driv=
ers
that are known to build but not to work on this arch'?

Best Regards,
Micha=B3 Miros=B3aw
