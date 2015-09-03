From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 05/19] ixgbe: Add support for UDP-encapsulated tx
 checksum offload
Date: Thu, 3 Sep 2015 00:21:26 +0000
Message-ID: <3391500E-A14E-456A-952D-8F71A3A587D5@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1441156443-33381-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <CALx6S34-mUvQyUQNcVC+o+NeUxWEsCG2GS=Eq++eGqoh=kv8kg@mail.gmail.com>
 <F63CFE64-29E1-484B-B19B-269FAAA9C54B@intel.com>
 <CALx6S36-CAWVme16XOT6Gj5HnkFCbkQgsSBPVjXbzWbRLnqYuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_30BBBBFB-34E7-4D98-9253-E2C2C19D2D23";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16736 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776AbbICAV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 20:21:27 -0400
In-Reply-To: <CALx6S36-CAWVme16XOT6Gj5HnkFCbkQgsSBPVjXbzWbRLnqYuw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_30BBBBFB-34E7-4D98-9253-E2C2C19D2D23
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Sep 2, 2015, at 4:21 PM, Tom Herbert <tom@herbertland.com> wrote:
>=20
> Mark, another question in this area of code. Looking at ixgbe_tx_csum,
> I'm wondering what happens with those default cases for the switch
> statements. If those are hit for whatever reason does that mean the
> checksum is never resolved? It seems like if the device couldn't
> handle these cases then skb_checksum_help should be called to set the
> checksum. In particular I am wondering what happens in the case that a
> TCP or UDP packet is sent in IPv6 with an extension header present (so
> default is taken in switch (l4_hdr)). Would the checksum be properly
> set in this case?

I will look further into this, but in a first look it appears that you =
are right and that it has been this way for some time.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_30BBBBFB-34E7-4D98-9253-E2C2C19D2D23
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJV55KGAAoJEDwO/+eO4+5u6SoP/1/TpBMDsueRWg9EdP2ufTw9
0u37hs07ABapt312yvmgbo8Vrygupe0brmOxxOpwouRCKnPDSaFLV8Y9TTL0qX2v
f9ZkWQx2K7tNeYQmieXaGC1L0dIWjoPD+PzUvXoAErpIhaldNFSadAMYT05bym9g
Z+wB2hzcXHEY0azypHgG+b5qajc6KPvIyLfchCbP3Hq278menDtkE2NnUVXUJRzo
H/aGUrQ7p7pX1TlZlSMn0Sy7sDu2z3aOdIW2M+tTKKUHQKnFFuq8G0/pidaYfvCY
Et/CtewXLyTEj4auKCMWj1bJ+fBJIVvC+TYg/9TPaaQ0MNVd05Um5vXbRGg/LX+2
eddUG82uoC9jJ6yZp8aqlBIQ3ivSzTpUia8n0G79RRzv1Nfwm8q94AEwXw3ghi//
bfmeRt1+ungcmsxw+on3P6AnQvh9e4dzYP2t9+Sx4Gu+8aIDc1fDueGs6g9MUhSw
GqdD1tP6X9bMvV2hv3e7bZFjNL9JI/Zv9mPVXnxCwQxAqtXlBrk/mTVP20VU1ZKZ
qkG3VzgPcEaTGANmBV1rEe8usnytWYf5v92MDjPn5BdL7ZctGRFHXkbc7TW0/iX2
spL5D58xOO6KBFyyTgytjFdcTEHJNXVuJYcAsZsuxeaAw8nOzdwCO2ZI86+aEbyM
NfHaWLdTo1ucCdyeE0MU
=BNTK
-----END PGP SIGNATURE-----

--Apple-Mail=_30BBBBFB-34E7-4D98-9253-E2C2C19D2D23--
