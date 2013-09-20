From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 42/51] DMA-API: usb: musb: use
 platform_device_register_full() to avoid directly messing with dma masks
Date: Fri, 20 Sep 2013 10:15:52 -0500
Message-ID: <20130920151552.GQ26101@radagast>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMnQk-0007sX-Ty@rmk-PC.arm.linux.org.uk>
 <20130920131125.GO26101@radagast>
 <20130920134938.GO25647@n2100.arm.linux.org.uk>
Reply-To: balbi@ti.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8713123321030954905=="
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
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20130920134938.GO25647@n2100.arm.linux.org.uk>
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

--===============8713123321030954905==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rKoHqF+aPLVth8b2"
Content-Disposition: inline

--rKoHqF+aPLVth8b2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Sep 20, 2013 at 02:49:38PM +0100, Russell King - ARM Linux wrote:
> On Fri, Sep 20, 2013 at 08:11:25AM -0500, Felipe Balbi wrote:
> > Hi,
> >=20
> > On Fri, Sep 20, 2013 at 12:14:38AM +0100, Russell King wrote:
> > > Use platform_device_register_full() for those drivers which can, to
> > > avoid messing directly with DMA masks.  This can only be done when
> > > the driver does not need to access the allocated musb platform device
> > > from within its callbacks, which may be called during the musb
> > > device probing.
> > >=20
> > > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> >=20
> > you want me to carry this one through my tree or you prefer getting my
> > Acked-by ? Either way works for me:
> >=20
> > Acked-by: Felipe Balbi <balbi@ti.com>
> >=20
> > there's also the third option of me setting up a branch with only this
> > patch and we both merge it, that'd also work.
>=20
> I think this patch is sufficiently stand-alone that it should be fine
> if you want to take it through your tree.  That may be better in the
> long run to avoid conflicts with this patch and any future work in
> this area during this cycle.

awesome, i'll take this one early next week.

--=20
balbi

--rKoHqF+aPLVth8b2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJSPGaoAAoJEIaOsuA1yqREE+MP/2yK4ec5lzVPs6fLeF9dUQHh
yWwfvqZLfu9D9lFIzGOOgfPm03or8ubh7i/ryfKBHxyKiGysUyo2yen3AwOwFgq1
2VbJzj55Zz5fejj7T9YE2hJPXU3ofUTdkNSJkbOGqnROvzNcCBYorIgcsAceohqP
biXh7G8wuxJmJqe967o/LVi9M4GL9ny+GqXdqT7TzuPeFzIwnlDpRL2+vgQDD3Y8
maW6NOBkrF8W7g2qM5qG4oT/LPNyIEAFpJqOYSQ14EgDp0VxviUl4kMDSqihMOM7
iPMQJPMhNKRx8vSUilrRxGCY636T0bSXZd1x6L+AIQ0XsTzEtFT73v929byiFNso
bzQpIOgJjrDgUfBi4MnOemhm98+/UhamcqoXq7v6FQ2FyhEMeIgArAIwwr3VxOf1
E7iiKaT7jVMRMcNZ+7UJsb+09vie5hGleu4M7YBayoxDEEtlWI8t0aOcngW8oVO4
DHD3uff/mpbTt9UYf7009WRToHXQwLMhbAimBcXbtya9Nxa79LNxT6aWEzfB2uVS
Ju5j7FEQZUsAMHQdJIUu+kpcEjrc5IKWWsedQul4piraIFh2Jb+8ODrGLEQvMq9e
8Jxl6hajoiw6zWfr+HMSqJa3MkDtaZ9GEOyvZqlnrBnpNS4dI3jZKDfresiz1fkq
o5bj9gHe6QmYbP9tPOOz
=V876
-----END PGP SIGNATURE-----

--rKoHqF+aPLVth8b2--

--===============8713123321030954905==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============8713123321030954905==--
