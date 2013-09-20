From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 42/51] DMA-API: usb: musb: use
 platform_device_register_full() to avoid directly messing with dma masks
Date: Fri, 20 Sep 2013 08:11:25 -0500
Message-ID: <20130920131125.GO26101@radagast>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMnQk-0007sX-Ty@rmk-PC.arm.linux.org.uk>
Reply-To: balbi@ti.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7929212992198795530=="
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-ide@vger.kernel.org,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 b43-dev@lists.infradead.org, linux-media@vger.kernel.org,
 devicetree@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-tegra@vger.kernel.org, linux-omap@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, Felipe Balbi <balbi@ti.com>,
 linux-crypto@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <E1VMnQk-0007sX-Ty@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

--===============7929212992198795530==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="S0GG+JvAI2G0KxBG"
Content-Disposition: inline

--S0GG+JvAI2G0KxBG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Sep 20, 2013 at 12:14:38AM +0100, Russell King wrote:
> Use platform_device_register_full() for those drivers which can, to
> avoid messing directly with DMA masks.  This can only be done when
> the driver does not need to access the allocated musb platform device
> from within its callbacks, which may be called during the musb
> device probing.
>=20
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

you want me to carry this one through my tree or you prefer getting my
Acked-by ? Either way works for me:

Acked-by: Felipe Balbi <balbi@ti.com>

there's also the third option of me setting up a branch with only this
patch and we both merge it, that'd also work.

cheers

--=20
balbi

--S0GG+JvAI2G0KxBG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJSPEl9AAoJEIaOsuA1yqREIKYP/0fcIrBOWMvkcjYUJYHm/Vg7
E8Vfe5ZUQcfPTWoiz5Kzdg+2Y4NG4Zv7Y7TpZj5atvz97zpiT0JAhvy5yf1+q3sv
qozJJL3JUtpbwcNP4R0/rD6v+2VvyS3lWuJeCI/NJY4zpZ6zYS8WsaR7QRnjUX8O
wOSIrYcwbr8xNrKIQxWhmEld60Cs4wSZ3TS8fvV0UWBo5CTeZdGZns/gRW5MGmZW
tdR1nB+KmCqpVga49niAMHKm0DqvBhrXyuZm3T7nrWxXnqY3/bhYM/sGNPAdeGU1
hJ6Hfe4yNjQpDm9bkRStj3kONevdXFpmnx7ndqnMGA+qAcZYUZP2ZQIP4zKUgPq5
iM/lX9z+NYtJPzUi2sV6XGHpU5+O2Imy0SP36IvsV3K9RbSv+MDsNqCQRdFzhQjX
dvR2fzXM6eX5zeRR9fonD3odCCr7sDGj8b+ODFhyp/Imph/e3spE0NWc/1et6KhY
OOXVb2MRpRBPwA8yjFOfLEn5rgu3u8awCHDe4rmknYVdmzzrZOowTSqw5q6UTK80
Vz+bJques9CHoUs2StfOeJ4QOn6mzaYi00HjqXZ3BZlBQSTKoPAAzC4H3vS/vPTs
9PSqsMPPkK4cFcq94JIViy9gzHUKWJREWjM9nmAKMfGdU+xxkTnYLurDBKZy6SAt
8zFqQe3pzsCzGEpNuH+i
=q3cb
-----END PGP SIGNATURE-----

--S0GG+JvAI2G0KxBG--

--===============7929212992198795530==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============7929212992198795530==--
