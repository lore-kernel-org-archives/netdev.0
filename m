From: Mark D Rustad <mrustad@gmail.com>
Subject: Re: [PATCH] net: ethernet: myricom: myri10ge: myri10ge.c:  Cleaning up missing null-terminate after strncpy call
Date: Sun, 10 Aug 2014 17:58:46 -0700
Message-ID: <85985E13-E12F-4C4A-A9AC-374C0E28312E@gmail.com>
References: <1407627638-24208-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: multipart/signed; boundary="Apple-Mail=_06A30A93-0794-459E-B0C0-3C4C3857649E"; protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: Hyong-Youb Kim <hykim@myri.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407627638-24208-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Apple-Mail=_06A30A93-0794-459E-B0C0-3C4C3857649E
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Aug 9, 2014, at 4:40 PM, Rickard Strandqvist =
<rickard_strandqvist@spectrumdigital.se> wrote:

> Added a guaranteed null-terminate after call to strncpy.
>=20
> Signed-off-by: Rickard Strandqvist =
<rickard_strandqvist@spectrumdigital.se>
> ---
> drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    1 +
> 1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c =
b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> index f3d5d79..de327b6 100644
> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> @@ -574,6 +574,7 @@ myri10ge_validate_firmware(struct myri10ge_priv =
*mgp,
>=20
> 	/* save firmware version for ethtool */
> 	strncpy(mgp->fw_version, hdr->version, sizeof(mgp->fw_version));
> +	mgp->fw_version[sizeif(mgp->fw_version) - 1] =3D '\0';

Surely you meant sizeof above. Did you really not even compile this?

> 	sscanf(mgp->fw_version, "%d.%d.%d", &mgp->fw_ver_major,
> 	       &mgp->fw_ver_minor, &mgp->fw_ver_tiny);

--=20
Mark Rustad, MRustad@gmail.com


--Apple-Mail=_06A30A93-0794-459E-B0C0-3C4C3857649E
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJT6BVGAAoJEDwO/+eO4+5u2LoQAIqUgCLRQ61r0ti20fkEPRTs
/MGKIurB8jjEjhoHdkd/nj5THBFCpDRaR42eUojhcIjkZWQh56oexxOdO24Z/Mei
C6vedGwSIbdFCb0TAe1iGuTfUntu2PKloHyRVNUqUB+mfxPlZe0W6lFGx6bmvx5c
JKoEFqUPLFhwhZwp+TLsfn+d7d4q6EwMYjDXYftMwLECWt9kxI9VNvMy7+mGY4XW
s4jeOd/uHgD/92s8BZuxn2JlwcucPPkRf63Ax0mI/msfYOuhW/JVWAWBshA36SKK
2KpfDuq6RIICLd5cG6WUsqOJ0G8mQSoScYOe1oagGPr7n8S/eGOBUbGsnTmXI6V1
SPn90kVk23oL9Rt9herNKLfMD2YvYwyyaR4dXI0EcYtpeQQ6YBmPfvd0Stbz38nQ
+4KsQ0RiPoSzUcelVE+ZkXpc30sCAzoi8BvkDJx2rYHB6Y1bihuhKwcrtiDlcsZJ
ZcCoWrMsOICyfC2CwR/K9mV69P6AOgRr9DsO9l/Oa06ESDrRMisa+xcIkJibyQif
2VlLji2uTrwBzllWcngmQ8BVk0SeKDmNup/HJe0nI55mwZXQ6RBNAaSlYo3j+03V
T8uYAk8cBSd8gOtrvmadAYDD2jVQL7u6B2CchswLgwN5r2AMl+xg6D4iIRa+ZIfG
42j0twQ4w8yvbo0KUaT/
=k1IK
-----END PGP SIGNATURE-----

--Apple-Mail=_06A30A93-0794-459E-B0C0-3C4C3857649E--
