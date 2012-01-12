From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool] ethtool: Correct register dump offsets for Intel
 82575 chipsets.
Date: Thu, 12 Jan 2012 05:11:02 -0800
Message-ID: <1326373862.2709.63.camel@jtkirshe-mobl>
References: <1324636371-5402-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LoejTsSID1fFGMeD8qed"
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7020 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751937Ab2ALNLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jan 2012 08:11:04 -0500
In-Reply-To: <1324636371-5402-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LoejTsSID1fFGMeD8qed
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-12-23 at 02:32 -0800, Kirsher, Jeffrey T wrote:
> From: Matthew Vick <matthew.vick@intel.com>
>=20
> When support was added to dump the registers on 82575 chipset devices,
> six register offsets (receive/transmit desc length, head, and tail)
> were incorrectly mapped. This patch remaps the offsets to the correct
> registers.
>=20
> Signed-off-by: Matthew Vick <matthew.vick@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  igb.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/igb.c b/igb.c
> index ec35d36..e0ccef9 100644
> --- a/igb.c
> +++ b/igb.c
> @@ -200,13 +200,13 @@ igb_dump_regs(struct ethtool_drvinfo *info, struct =
ethtool_regs *regs)
>         /* Receive descriptor registers */
>         fprintf(stdout,
>                 "0x02808: RDLEN  (Receive desc length)                 0x=
%08X\n",
> -               regs_buff[142]);
> +               regs_buff[137]);
>         fprintf(stdout,
>                 "0x02810: RDH    (Receive desc head)                   0x=
%08X\n",
> -               regs_buff[146]);
> +               regs_buff[141]);
>         fprintf(stdout,
>                 "0x02818: RDT    (Receive desc tail)                   0x=
%08X\n",
> -               regs_buff[150]);
> +               regs_buff[145]);
>=20
>         /* Transmit control register */
>         reg =3D regs_buff[38];
> @@ -226,13 +226,13 @@ igb_dump_regs(struct ethtool_drvinfo *info, struct =
ethtool_regs *regs)
>         /* Transmit descriptor registers */
>         fprintf(stdout,
>                 "0x03808: TDLEN       (Transmit desc length)           0x=
%08X\n",
> -               regs_buff[214]);
> +               regs_buff[219]);
>         fprintf(stdout,
>                 "0x03810: TDH         (Transmit desc head)             0x=
%08X\n",
> -               regs_buff[218]);
> +               regs_buff[223]);
>         fprintf(stdout,
>                 "0x03818: TDT         (Transmit desc tail)             0x=
%08X\n",
> -               regs_buff[222]);
> +               regs_buff[227]);
>=20
>=20
>         fprintf(stdout,
> --
> 1.7.7.4
>=20

Ben, what is the status of this patch?

--=-LoejTsSID1fFGMeD8qed
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPDtvmAAoJEOVv75VaS+3O1GQP/iJaF+AVqMRaCHMqKWOea3qs
6gPXVYQ99XlHn4FcrGdPhZSt/d/8X+9TOcdMfOuVi53dyH5GwL4MGmK9HN4fBwpP
vVMDkz5IAdnPvTZnGAL2Wczv3EFLiP250BEGeYmIlZN0UPfqXNqZPXzJZhYfyCAK
4NUzsRO2bI3Ygaak6o/6AI4s6oIqOJFRc7pKisJmlJWthVRiwnv6d7OsmOvaIx2q
kkmYxYsqQIDZfVI4xZr68n9JHN3ValQNYW89yoGqL8yj/hVSRbqTYUC6qNCWARar
Uwme51klXiTEn9njsFomBl3gRY5+nHDDmAQ0UOss1NpxPptOYCDzyCLvhLI+iv8k
Pc7j4b3K+fVMJ7aFO1CFTrWnDbLWX6cyiq6wakuogb/RwjUf89/Jzbc5/P0T30+E
ppgXqE8mVOz02h/hH6XDpa9RXrM3JiTGi4e44lUGi+OXD/nVVeuivIp9SmSqF6BQ
gPeC1fGjZaT3j/9os7ZHDOuQR5THCRwJ4YY6Nk8x3iLp5NXggv3/UBIpJxJj9nvH
FNlZfsDsRZZm2lQhl3tzlZ+322/GUBDu87H9ozFeTA/YP8l74+sKUrLVy4TJ1VM+
MnY+eE30xHCwGJaEgdUY3avwzfqcnRA1hMogkEIhwHL43xXLW6KqCGyjMdwYSiYI
aytsxVdEq/p94zy+RegG
=q3qp
-----END PGP SIGNATURE-----

--=-LoejTsSID1fFGMeD8qed--
