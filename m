From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [PATCH 7/7] venet: add scatter-gather/GSO support
Date: Mon, 03 Aug 2009 15:57:59 -0400
Message-ID: <4A774147.8090207@novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>	<20090803171807.17268.49836.stgit@dev.haskins.net> <20090803113355.734e69b6@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig729E2AC306E0E4CAC25F29DB"
Cc: linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754955AbZHCT6H@vger.kernel.org>
In-Reply-To: <20090803113355.734e69b6@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig729E2AC306E0E4CAC25F29DB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Stephen Hemminger wrote:
> On Mon, 03 Aug 2009 13:18:07 -0400
> Gregory Haskins <ghaskins@novell.com> wrote:
>=20
>> +	struct {
>> +		int                sg:1;
>> +		int                tso:1;
>> +		int                ufo:1;
>> +		int                tso6:1;
>> +		int                ecn:1;
>> +	} flags;
>=20
> Why do you have to shadow flags that are already available in net_devic=
e?
> It is bad design to replicate state in a device driver. The problem
> with replicated state is that it has to be updated in both places.
>=20

Ya, you are right.  I think the rationale was that the flags were "hw"
state, whereas dev->features was software state.  But thinking about it
after you comments, I don't think it makes much difference either way.

I will just have the negcap() function set the features directly in v2.

Kind Regards,
-Greg


--------------enig729E2AC306E0E4CAC25F29DB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkp3QUcACgkQP5K2CMvXmqFApwCfWvniqvhjljwRK06ZywYww8TL
HeIAn12tmTF1vrt/U2eqFygxMuqhhTE/
=TQZc
-----END PGP SIGNATURE-----

--------------enig729E2AC306E0E4CAC25F29DB--
