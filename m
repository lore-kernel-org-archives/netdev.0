From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH 5/7] ssb: Use bool function return values of true/false
 not 1/0
Date: Mon, 30 Mar 2015 19:49:01 +0200
Message-ID: <20150330194901.5293fbe2@wiggum>
References: <cover.1427736972.git.joe@perches.com>
 <57da8293b865fb2d119e29073aec54323fc10000.1427736972.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/QAah0TnE_6kMwgY1Dyk0f+8"; protocol="application/pgp-signature"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57da8293b865fb2d119e29073aec54323fc10000.1427736972.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/QAah0TnE_6kMwgY1Dyk0f+8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 30 Mar 2015 10:43:21 -0700
Joe Perches <joe@perches.com> wrote:

> Use the normal return values for bool functions
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/ssb/driver_gige.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/ssb/driver_gige.c b/drivers/ssb/driver_gige.c
> index e973405..ebee6b0 100644
> --- a/drivers/ssb/driver_gige.c
> +++ b/drivers/ssb/driver_gige.c
> @@ -242,7 +242,7 @@ static int ssb_gige_probe(struct ssb_device *sdev,
>  bool pdev_is_ssb_gige_core(struct pci_dev *pdev)
>  {
>  	if (!pdev->resource[0].name)
> -		return 0;
> +		return false;
>  	return (strcmp(pdev->resource[0].name, SSB_GIGE_MEM_RES_NAME) =3D=3D 0);
>  }
>  EXPORT_SYMBOL(pdev_is_ssb_gige_core);

Looks good.

Signed-off-by: Michael Buesch <m@bues.ch>

Kalle, can you take this one, please?

--=20
Michael

--Sig_/QAah0TnE_6kMwgY1Dyk0f+8
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVGYyNAAoJEPUyvh2QjYsOEjkP/0B4IzFxBSGURlzzmvDyKx1g
ACCgIPm1r79OWqushSMktb+5Ys1XFgrr+cT0I2JdvIfRQhsfmUJrAgjstvfrmB8d
8bpofcRT9lrhRf6XO0/FozK7Was7hb1IBrksZyk4AF3SnYfzj936gGFkLSsAc+ZB
68bnL3UFK+M3EPlLVuJJ6eioWhsyDN8g1sd/ARe2fWxR0NFFvF9ulA6AbYG8NQ1P
yvaf5tzT1t0WwYZaAxgOi5hC/TDtAFJbB6GLuRMbNE5Xpk1Nf/wwCcjhLrRUvFm4
m30GtpqsKtL8dtlDgxiHmB2CJhcDZAvOwpakaMAJ1AxG1F0Ce72d06BizsMxM1aS
Xf6atAQqXjtAbNrePFMp+8COGoLEmEZMWP/+hI+ZKV8xiOBwzEyCTFSvg688JDc+
MDbSrwbkZxvgvE0u0dsn/BilWbF2zLy7wr9gLlvZI+tW/eagnizRiOpeEdsX57qM
Okp/2nFSuh55OsCXdqp6+YdSweyt/VS8TOB7ggY7VPeRn5CbN8ujOxes1ZTCypIq
uUSWoTXMgu4me20xY+QyjQ32dFz/SIJucrTZM/kLko0vdacPHDI3VwqMnmwc4Ta7
cUpv4B9Ba62myoW7ODp4i5bmABXHUtgj4pDiXmSpQhEPjMGBw9gmr1xFTgyIUN4d
S0PLe1qqSbYQRqVia0WJ
=r4ES
-----END PGP SIGNATURE-----

--Sig_/QAah0TnE_6kMwgY1Dyk0f+8--
