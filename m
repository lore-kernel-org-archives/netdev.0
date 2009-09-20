From: Christopher Zimmermann <madroach@zakweb.de>
Subject: Re: SO_TIMESTAMPING fix and design decisions
Date: Sun, 20 Sep 2009 09:52:42 +0200
Message-ID: <20090920095242.5cd42f1a@pundit>
References: <20090919192549.0735c93a@pundit>
	<1253398161.14869.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/neaqIQeBEu1bega.EG6S+t9";
 protocol="application/pgp-signature"
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:57134 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbZITHx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 03:53:28 -0400
In-Reply-To: <1253398161.14869.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/neaqIQeBEu1bega.EG6S+t9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 19 Sep 2009 15:09:21 -0700
Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> wrote:

> > hardware timestamps only work for the Intel igb driver. I have=20
> > access to two test machines with NICs supported by this driver.
>=20
> Intel's 82599, supported by ixgbe, also has the same IEEE 1588
> timestamping support in hardware.  We haven't implemented the support
> yet in ixgbe, but the hardware is there and does work.  If you were
> curious of the interface, the datasheet for the hardware is available on
> our SourceForge site (e1000.sf.net).

hi! thanks for the reply.

I already got the documentation for the 82576 cards I have access to. I=20
won't be able to afford another pair.

What do you think about my idea to expose the relevant registers to=20
userspace? I believe it would not be too difficult for userspace to=20
configure the timestamps this way and would allow way more flexibility.=20
Of course I would #DEFINE the constants used to set the registers.

Christopher Zimmermann

--Sig_/neaqIQeBEu1bega.EG6S+t9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkq130oACgkQET+LZnf0EFwj1gCeP2O16PmQJSUBwTkukCjqpnwX
44AAnjohMg55zAIaUS5PYhettzuQVDHK
=38nF
-----END PGP SIGNATURE-----

--Sig_/neaqIQeBEu1bega.EG6S+t9--
