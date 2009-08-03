From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH 7/7] venet: add scatter-gather/GSO support
Date: Mon, 03 Aug 2009 15:30:10 -0400
Message-ID: <4A773AC2.2080106@gmail.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>	<20090803171807.17268.49836.stgit@dev.haskins.net> <20090803113225.4cd414ec@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBE4790AD4B3E23612DA70C1F"
Cc: Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754628AbZHCThT@vger.kernel.org>
In-Reply-To: <20090803113225.4cd414ec@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBE4790AD4B3E23612DA70C1F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Stephen Hemminger wrote:
> On Mon, 03 Aug 2009 13:18:07 -0400
> Gregory Haskins <ghaskins@novell.com> wrote:
>=20
>> SG/GSO significantly enhance the performance of network traffic under
>> certain circumstances.  We implement this feature as a separate patch
>> to avoid intially complicating the baseline venet driver.  This will
>> presumably make the review process slightly easier, since we can
>> focus on the basic interface first.
>>
>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
>=20
> Never mind, previous comment about adding TSO.


I should probably fold 6+7 together anyway, so this was my fault.  I
think I was originally keeping them separate because the venet was
serving as the canonical example for the vbus interface.  But Ill just
come up with something simpler to demonstrate the interface and merge
these two patches.

> But it still would be good to have ethtool interface for this.

Ack.  Will do.

Thanks Stephen,
-Greg


--------------enigBE4790AD4B3E23612DA70C1F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkp3OsIACgkQP5K2CMvXmqGqYgCgh9VC2+3otM51psFaHNp8HUTe
h6oAn2gmbKCnW5Ip/KC2EfEp7rvhIEX8
=NES1
-----END PGP SIGNATURE-----

--------------enigBE4790AD4B3E23612DA70C1F--
