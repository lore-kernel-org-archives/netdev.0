From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: Driver build-testing (was: [PATCH] net: dm9000: Fix build)
Date: Mon, 18 Apr 2011 13:25:22 +0100
Message-ID: <20110418122522.GC9462@sirena.org.uk>
References: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com> <20110418111203.GB18324@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Micha? Miros?aw <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:52756 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab1DRMZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 08:25:23 -0400
Content-Disposition: inline
In-Reply-To: <20110418111203.GB18324@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 01:12:03PM +0200, Micha? Miros?aw wrote:
> On Mon, Apr 18, 2011 at 12:04:37PM +0100, Mark Brown wrote:
> > Commit c88fcb (net: dm9000: convert to hw_features) broke the build of
> > the dm9000 driver since it merged functions which use different names
> > for the board info structure used for I/O operations without updating
> > all the references to use the same name. Fix that.

> This brings the issue of build testing effectiveness. In current code
> there is no configuration that makes all drivers build. I would like
> to see something like 'make brokenconfig' that would allow most of
> the code to be built, and not necessarily working. Maybe someone has
> an idea how to implement that?

For the drivers that genuinely are rather platform specific this tends
to fail very badly as you need headers that only come along with the
architecture.

In the case of DM9000 if it fails to build on your platform then the
driver is just buggy - looking at the Kconfig I rather suspect that the
dependency on architectures should just be removed.
