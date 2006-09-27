From: Bernd Eckenfels <be-mail2006@lina.inka.de>
Subject: Re: Bug#389804: mii-tool gigabit support.  (fwd)
Date: Wed, 27 Sep 2006 22:57:21 +0200
Message-ID: <20060927205721.GA3688@lina.inka.de>
References: <Pine.LNX.4.64.0609271225070.2299@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 389804@bugs.debian.org, Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from quechua.inka.de ([193.197.184.2]:61393 "EHLO mail.inka.de")
	by vger.kernel.org with ESMTP id S1030831AbWI0U5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 16:57:30 -0400
To: dean gaudet <dean@arctic.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0609271225070.2299@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2006 at 12:27:48PM -0700, dean gaudet wrote:
> Package: net-tools
> Version: 1.60-17
>=20
> the version of mii-tool referenced below (plus the patch below) provi=
des=20
> support for more mii types, and more importantly, allows it to report=
=20
> 1000baseT link states (which are otherwise misreported as 100baseT).
>=20
> please upgrade the version in net-tools... thanks!

thanks, I have added that to HEAD of net-tools CVS, will also be in nex=
t
debian package version.

cvs: http://net-tools.berlios.de

> On Tue, 26 Sep 2006, Stephen Hemminger wrote:
> > The mii-tool utility seems to be abandoned and unmaintained?
> >=20
> > Here is a version that does standard 1000baseT support.
> > 	http://developer.osdl.org/shemminger/prototypes/mii-tool.tar.bz2
=2E..
> +    for (i =3D 0; i < ((verbose > 1) ? 32 : MII_BASIC_MAX); i++)
=2E..
--=20
  (OO)     -- Bernd_Eckenfels@M=F6rscher_Strasse_8.76185Karlsruhe.de --
 ( .. )    ecki@{inka.de,linux.de,debian.org}  http://www.eckes.org/
  o--o   1024D/E383CD7E  eckes@IRCNet  v:+497211603874  f:+497211515161=
29
(O____O)  When cryptography is outlawed, bayl bhgynjf jvyy unir cevinpl=
!
