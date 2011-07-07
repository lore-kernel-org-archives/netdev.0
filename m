From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: 3.0.0rc6: ethtool not working without a cable
Date: Thu, 7 Jul 2011 18:47:14 +0200
Message-ID: <201107071847.14362.a.miskiewicz@gmail.com>
References: <201107061338.08573.a.miskiewicz@gmail.com> <1309971146.6217.0.camel@jbrandeb-mobl.amr.corp.intel.com> <201107061857.21206.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel" <e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:64348 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530Ab1GGQrT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 12:47:19 -0400
Received: by fxd18 with SMTP id 18so1258612fxd.11
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 09:47:18 -0700 (PDT)
In-Reply-To: <201107061857.21206.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 of July 2011, Arkadiusz Miskiewicz wrote:
> On Wednesday 06 of July 2011, Brandeburg, Jesse wrote:
> > On Wed, 2011-07-06 at 08:26 -0700, Ben Hutchings wrote:
> > > On Wed, 2011-07-06 at 16:53 +0200, Arkadiusz Miskiewicz wrote:
> > > > On Wednesday 06 of July 2011, Ben Hutchings wrote:
> > > > > On Wed, 2011-07-06 at 13:38 +0200, Arkadiusz Miskiewicz wrote=
:
> > > > > > 3.0.0rc6, thinkpad t400 notebook.
> > > > > >=20
> > > > > > If there is no cable then ethtool reports no device. It was=
n't
> > > > > > that before AFAIK.
> > > > > >=20
> > > > > > ethtool version 2.6.36
> >=20
> > snip
> >=20
> > > Then the only other explanation I can think of is that the driver=
 has
> > > 'detached' the device due to some kind of error.  The ethtool cor=
e does
> > > have a check for that.
> >=20
> > could it be that aspm is enabled
>=20
> I have CONFIG_PCIEASPM=3Dy
>=20
> > or that you've enabled runtime power
> > management?
>=20
> In e1000e? no (unless it's default somehow).

And if this is normal behaviour (when apsm is enabled) then maybe ethto=
ol=20
could disable apsm/power management for device for time of querying?

--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
