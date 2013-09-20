From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 28/51] DMA-API: sound: fix dma mask handling in a lot of
 drivers
Date: Fri, 20 Sep 2013 17:36:54 +0100
Message-ID: <20130920163654.GN21013@sirena.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMm9m-0007ij-ER@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4406136581201344290=="
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 Takashi Iwai <tiwai@suse.de>, linux-mmc@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-nvme@lists.infradead.org,
 Jaroslav Kysela <perex@perex.cz>, Peter Ujfalusi <peter.ujfalusi@ti.com>,
 linux-ide@vger.kernel.org, devel@driverdev.osuosl.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 e1000-devel@lists.sourceforge.net, b43-dev@lists.infradead.org,
 linux-media@vger.kernel.org, devicetree@vger.kernel.org,
 Haojian Zhuang <haojian.zhuang@gmail.com>, Timur Tabi <timur@tabi.org>,
 Kukjin Kim <kgene.kim@samsung.com>, dri-devel@lists.freedesktop.org,
 Ben Dooks <ben-linux@fluff.org>, linux-tegra@vger.kernel.org,
 linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 Eric Miao <eric.y.miao@gmail.com>, Sangbeom Kim <sbkim73@samsu
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <E1VMm9m-0007ij-ER@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============4406136581201344290==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NbUNL4d9A9kY58qh"
Content-Disposition: inline


--NbUNL4d9A9kY58qh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 19, 2013 at 10:53:02PM +0100, Russell King wrote:
> This code sequence is unsafe in modules:
>=20
> static u64 mask =3D DMA_BIT_MASK(something);
> ...
> 	if (!dev->dma_mask)
> 		dev->dma_mask =3D &mask;

Acked-by: Mark Brown <broonie@linaro.org>

--NbUNL4d9A9kY58qh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBAgAGBQJSPHmjAAoJELSic+t+oim9WB4QAINsf282vDwWmQYHGXTeorHo
q0pJ/9bTwBrSE0KzOK9H6UvL7oxCgzMPOT8RiSjWcdEXX/FavpH1TCf+ETkaYyEA
NaPvO/uUV/99qWhM/PJQvtv4yxhIR7ENiZKywUuFnWQuc44yGUWBLK8ooA4xXtme
WMcWyy7SMMcP/+9eBd9aNe1FPYFirsqSrrCpWSR/fD+TWFKMB6HG+OZGNYRFMrRm
Xet5sWMGwzBiL453M0ujAEHKd/g4VOkweCydEq+2Rt2am6ph+SrMuoQvCDZ1bvbh
71nyYA+j2xNy8jb7AA9PukWoeXyAI0xRY8zh939Uvdxf4SPUIVgw9wJE5rMRGoT5
k4We/z2A4m1DGCtg1JQN86HAe7jv3YlGLoPOhsrOnOEV55VnXIz0Lm9x3HjTNfvG
LcJXBGeHmU3Jvj3JEpA57YDbOhpwx0klK7RS5v6BjIJrJUSwjATqt1WQVr528HDp
rXQpUqxUL3KObdlA5TYweR2I0KxWe47rw612XGqhRiI+equSdTDP770QsO1nXlsA
qCfn3Gh7t+hyB3yFZUquWEXwKVv0YMh3Ds/bR2RtZluSl3SzM9n/Dp45w6SMu1LN
oSpxUS7KNzTPXQp0kns7dDFnJJWXid7mUScjK4rc5pSyBF4NSEqJsmqHm0whd/qL
uR8J7AFq8DkXx3g+/4gf
=H53r
-----END PGP SIGNATURE-----

--NbUNL4d9A9kY58qh--


--===============4406136581201344290==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============4406136581201344290==--
