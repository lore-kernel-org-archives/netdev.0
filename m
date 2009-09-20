From: Christopher Zimmermann <madroach@zakweb.de>
Subject: Re: SO_TIMESTAMPING fix and design decisions
Date: Sun, 20 Sep 2009 20:50:47 +0200
Message-ID: <20090920205047.0f2df70c@pundit>
References: <20090919192549.0735c93a@pundit>
 <1253398161.14869.2.camel@localhost.localdomain>
 <20090920095242.5cd42f1a@pundit>
 <1253468893.2654.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/vaGv7=19pSU43GUP8u_JBAi";
 protocol="application/pgp-signature"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:61100 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256AbZITSvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 14:51:35 -0400
In-Reply-To: <1253468893.2654.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/vaGv7=19pSU43GUP8u_JBAi
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 20 Sep 2009 10:48:13 -0700
Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> wrote:

> On Sun, 2009-09-20 at 00:52 -0700, Christopher Zimmermann wrote:
> > On Sat, 19 Sep 2009 15:09:21 -0700
> > Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> wrote:
> >=20
> > > > hardware timestamps only work for the Intel igb driver. I have=20
> > > > access to two test machines with NICs supported by this driver.
> > >=20
> > > Intel's 82599, supported by ixgbe, also has the same IEEE 1588
> > > timestamping support in hardware.  We haven't implemented the support
> > > yet in ixgbe, but the hardware is there and does work.  If you were
> > > curious of the interface, the datasheet for the hardware is available=
 on
> > > our SourceForge site (e1000.sf.net).
> >=20
> > hi! thanks for the reply.
> >=20
> > I already got the documentation for the 82576 cards I have access to. I=
=20
> > won't be able to afford another pair.
> >=20
> > What do you think about my idea to expose the relevant registers to=20
> > userspace? I believe it would not be too difficult for userspace to=20
> > configure the timestamps this way and would allow way more flexibility.=
=20
> > Of course I would #DEFINE the constants used to set the registers.
>=20
> The patch seems reasonable, but I haven't played with the igb
> timestamping very much.  However, what impact will this have on the
> existing ptpd userspace daemon?

It will need to be modified. If you want to avoid this, one could keep=20
the HWTSTAMP_FILTER_PTP_.... defines and just redifine them to reflect=20
the new interface.
Where can I find this ptpd userspace daemon, which supports hardware=20
timestamps using the ioctl interface? ptpd.sourceforge.net doesn't.


Cheers,

Christopher Zimmermann

--Sig_/vaGv7=19pSU43GUP8u_JBAi
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkq2eYcACgkQET+LZnf0EFx7DQCgx2ANFLzepaCcPgql1WEkQmeg
1hwAn3o6fesOkmfktDjBbM/prXQVu+eu
=lJjf
-----END PGP SIGNATURE-----

--Sig_/vaGv7=19pSU43GUP8u_JBAi--
