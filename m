From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: 3.0.0rc6: ethtool not working without a cable
Date: Wed, 6 Jul 2011 18:57:21 +0200
Message-ID: <201107061857.21206.a.miskiewicz@gmail.com>
References: <201107061338.08573.a.miskiewicz@gmail.com> <1309966010.2712.4.camel@bwh-desktop> <1309971146.6217.0.camel@jbrandeb-mobl.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel" <e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:58742 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862Ab1GFQ5Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 12:57:25 -0400
Received: by fxd18 with SMTP id 18so270233fxd.11
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 09:57:24 -0700 (PDT)
In-Reply-To: <1309971146.6217.0.camel@jbrandeb-mobl.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 of July 2011, Brandeburg, Jesse wrote:
> On Wed, 2011-07-06 at 08:26 -0700, Ben Hutchings wrote:
> > On Wed, 2011-07-06 at 16:53 +0200, Arkadiusz Miskiewicz wrote:
> > > On Wednesday 06 of July 2011, Ben Hutchings wrote:
> > > > On Wed, 2011-07-06 at 13:38 +0200, Arkadiusz Miskiewicz wrote:
> > > > > 3.0.0rc6, thinkpad t400 notebook.
> > > > >=20
> > > > > If there is no cable then ethtool reports no device. It wasn'=
t that
> > > > > before AFAIK.
> > > > >=20
> > > > > ethtool version 2.6.36
>=20
> snip
>=20
> > Then the only other explanation I can think of is that the driver h=
as
> > 'detached' the device due to some kind of error.  The ethtool core =
does
> > have a check for that.
>=20
> could it be that aspm is enabled=20

I have CONFIG_PCIEASPM=3Dy

> or that you've enabled runtime power
> management?

In e1000e? no (unless it's default somehow).

--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
