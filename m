From: Micha? Miros?aw <mirq-linux@rere.qmqm.pl>
Subject: Re: Driver build-testing (was: [PATCH] net: dm9000: Fix build)
Date: Mon, 18 Apr 2011 16:51:02 +0200
Message-ID: <20110418145102.GA2555@rere.qmqm.pl>
References: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com> <20110418111203.GB18324@rere.qmqm.pl> <20110418122522.GC9462@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51996 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754338Ab1DROvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 10:51:04 -0400
Content-Disposition: inline
In-Reply-To: <20110418122522.GC9462@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 01:25:22PM +0100, Mark Brown wrote:
> On Mon, Apr 18, 2011 at 01:12:03PM +0200, Micha? Miros?aw wrote:
> > On Mon, Apr 18, 2011 at 12:04:37PM +0100, Mark Brown wrote:
> > > Commit c88fcb (net: dm9000: convert to hw_features) broke the bui=
ld of
> > > the dm9000 driver since it merged functions which use different n=
ames
> > > for the board info structure used for I/O operations without upda=
ting
> > > all the references to use the same name. Fix that.
> > This brings the issue of build testing effectiveness. In current co=
de
> > there is no configuration that makes all drivers build. I would lik=
e
> > to see something like 'make brokenconfig' that would allow most of
> > the code to be built, and not necessarily working. Maybe someone ha=
s
> > an idea how to implement that?
> For the drivers that genuinely are rather platform specific this tend=
s
> to fail very badly as you need headers that only come along with the
> architecture.
>=20
> In the case of DM9000 if it fails to build on your platform then the
> driver is just buggy - looking at the Kconfig I rather suspect that t=
he
> dependency on architectures should just be removed.

I wonder if allyesconfig/allmodconfig is supposed to include code that'=
s
known not to work for a particular architecture.

Best Regards,
Micha=B3 Miros=B3aw
