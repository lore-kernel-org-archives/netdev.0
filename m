From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH 2/2 v4] net/smsc911x: Add regulator support
Date: Mon, 31 Oct 2011 14:21:15 -0400
Message-ID: <201110311421.18653.vapier@gentoo.org>
References: <1320064719-14449-1-git-send-email-robert.marklund@stericsson.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2026611.Zm7YYLeAMb";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirier <mathieu.poirier@linaro.org>,
	Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Tony Lindgren <tony@atomide.com>, linux-omap@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Robert Marklund <robert.marklund@stericsson.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1320064719-14449-1-git-send-email-robert.marklund@stericsson.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2026611.Zm7YYLeAMb
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 31 October 2011 08:38:39 Robert Marklund wrote:
> ChangeLog v3->v4:
> - Remove dual prints and old comment on Mike's request.
> - Split the request_free fucntion on Mike and Sascha request.

would be nice if the enable/disable were split as well ...

>  	iounmap(pdata->ioaddr);
>=20
> +	(void)smsc911x_enable_disable_resources(pdev, false);

i don't think the (void) cast is necessary

otherwise looks fine
=2Dmike

--nextPart2026611.Zm7YYLeAMb
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJOruceAAoJEEFjO5/oN/WBcEAP/37XHSiSXFvf1xdbFmVmVH20
I9kwyxsxV/A7v3czWCf88uAXhOeDGVC7gWesSDt1qgighu3HK+Idyjegg1T2lsG+
m0v98wG1b/RQDJJ0NJq+0xoqY9va0qLw27Y6S0Bkzg9fYfElFoRQr9p68cFnY9rO
25oT6Ebd8ha7LyrN8pQXv8Ghy3ZN2Lhr/zvasbfE8wFTRddoqBmWSHWtlslZXxcx
fjMEVMr1L5PoBiCD1v4ZM77k3BXPBL2kLFmW2PxI5S3gCCfj7UKXBKtozbsw6VpX
6/AyWnRSK08kziBnmEcisNitjElBrk4hS/5j4zkHlvQ8PnTRfWBlSeqKw3NW0Euu
51usSjczj22TepHaELzpkvAHNPG5IC336ZXGvlI7JUUYM4qfN1d+FDj2V5izgOpM
mZBs+PfYSRRCrwv5h7bXkAov4RUdNEWWo34y9U58ulbWFF50L0FrwCdp3Hn7ywSI
cLng/BSg726VMrVDZuk4UvFUzx+1YlaJw6E4HTdUDWyw4y+dEMXH8pUQcIF4tWoA
nK/CxWeyB1GMMwNrKDyWiwi1H5MzkCQ3VDKJK0MSuN4GA3WRMMg1nUH2xpNxNAmy
sOiOIUPFpLzc/GvKxVZNVKAxYm7aXb8kP9J/wsjsj3XLnhYkCOf9WMIpPDG9XcRR
TtXLTcJxl/QS/hLcqRj+
=zKGV
-----END PGP SIGNATURE-----

--nextPart2026611.Zm7YYLeAMb--
