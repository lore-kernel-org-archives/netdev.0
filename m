From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 12/51] DMA-API: net: intel/e1000: replace
 dma_set_mask()+dma_set_coherent_mask() with new helper
Date: Fri, 20 Sep 2013 12:45:55 -0700
Message-ID: <1379706355.1972.8.camel@jtkirshe-mobl>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMluG-0007gV-6y@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7923185765950412603=="
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 linux-mmc@vger.kernel.org,
 Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
 linux-fbdev@vger.kernel.org, linux-nvme@lists.infradead.org,
 linux-ide@vger.kernel.org, Carolyn Wyborny <carolyn.wyborny@intel.com>,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 Don Skidmore <donald.c.skidmore@intel.com>,
 Jesse Brandeburg <jesse.brandeburg@intel.com>, b43-dev@lists.infradead.org,
 linux-media@vger.kernel.org, Alex Duyck <alexander.h.duyck@intel.com>,
 devicetree@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>,
 dri-devel@lists.freedesktop.org, linux-tegra@vger.kernel.org,
 linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 netdev@vger.kernel.org, linux-usb
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <E1VMluG-0007gV-6y@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org


--===============7923185765950412603==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IwGSEViKnlGxN4Ur4LPe"


--=-IwGSEViKnlGxN4Ur4LPe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-09-19 at 22:37 +0100, Russell King wrote:
> Replace the following sequence:
>=20
>         dma_set_mask(dev, mask);
>         dma_set_coherent_mask(dev, mask);
>=20
> with a call to the new helper dma_set_mask_and_coherent().
>=20
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |    9 ++-------
>  1 files changed, 2 insertions(+), 7 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-IwGSEViKnlGxN4Ur4LPe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSPKXzAAoJEOVv75VaS+3OXRMP/0inX8RE/LpymWBicNP8WD6j
xJGDMRHzZ+Frac/Q0qSWiCNSvfBn/WZ9glR0uxnIz51/TjfFzITWZBzcsgeVJlAv
BAQt/pIzXrw1Qwwcnm3ZGBJ6XhGFQ8rI+6Fv/1nQ7peb1PoVjpM+pkGszhgOD7AZ
KU0EqTKIIGnRKxdVZwraXXEIrrwCwEnEJnHylot3scVYOEww+8UkQzp1ItDHeXuD
FQurkbrCawaVB7bctDl45kmo66I+Pn6SLo22LFDI7m8Q92KePKR0pNHv4dLuRrh2
5j6S2j1jeZca3DT0dFzyV1jgBjOzWmHfA38yHpk0FesH+3DAlTgkTxLc2PpARAww
cKqu5d/i1rk0INt61H6tp3qYWH7HQ563PW9aIxX82PsRdXtedvTUjtxAZ/kIWAUQ
uFX5Q0Y0u9XlfC8spRAcUvi9AxKATY/mDXcd1oBFO2yLYWcfo/2R4THAqz/yjhea
KQQVh9gE2Uc06/fWbh2W+uGdluMNJJSEKTbkNxea2w9+MEGLV9+Cjdfb9x/w4oMf
vT5rD9lIZh1k9xZGjB++HrOd6Gy6l9j+wYQqIiC0Ut9P5gOjrd2gyhg3xzvz894/
eYO6FFFLJeQijLVHEU5nUVg+0IQQQaUc0Cq6WGr/USpjapQUq0xuQLLRCaph1uPM
crlJOl4YrRaaUMl8RxDR
=UEsD
-----END PGP SIGNATURE-----

--=-IwGSEViKnlGxN4Ur4LPe--


--===============7923185765950412603==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============7923185765950412603==--
