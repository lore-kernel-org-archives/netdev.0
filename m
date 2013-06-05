From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [net-next PATCH v4 1/5] net: cpsw: enhance pinctrl support
Date: Wed, 5 Jun 2013 20:23:45 +0100
Message-ID: <20130605192345.GH31367@sirena.org.uk>
References: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com>
 <1370452099-24026-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5837998748277611889=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Hebbar Gururaja <gururaja.hebbar-l0cyMroinI0@public.gmane.org>, benoit.cousson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1370452099-24026-2-git-send-email-mugunthanvnm-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org


--===============5837998748277611889==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kY7Q1I7FwGue0/xS"
Content-Disposition: inline


--kY7Q1I7FwGue0/xS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 05, 2013 at 10:38:15PM +0530, Mugunthan V N wrote:
> From: Hebbar Gururaja <gururaja.hebbar-l0cyMroinI0@public.gmane.org>
>=20
> Amend cpsw controller to optionally take a pin control handle and set
> the state of the pins to:
>=20
> - "default" on boot, resume
> - "sleep" on suspend()

Linus Walleij posted some patches which factor the state setting code
out into generic functions earlier on today - it probably makes sense to
pick those up rather than open coding

--kY7Q1I7FwGue0/xS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBAgAGBQJRr5A+AAoJELSic+t+oim9Tt4P/2kgMjKssw6c6sBUmpjPw9Ft
dX0eBErXLq62o0+KLDsEF+2sRXB++lNC1BIMpFLh19ocKVIsG5EIR78nny7yvHEH
y/agXhUN6js3YpKKmQ2AOTJEGLtrJ5PRnW1/q6NVFDwlaf1gNHOXQ3m3DTBwJE9z
FjNeUm4PBBbT8DD80ks2y+IE4PMki3ubxPAPtMxlf+4DdmbsSziIKXXU1pyHkM6c
14xw+Chv2dIikoHPx7JTE8tteL/YIFTAYQQo2n7URXe5CIBdTW5nHzjZ87nmBQZN
uwe1GV7B+cMxt3wqfptoUAEkf0s8FEns1eKumcyCreXK4YtvpYSfwcHrM9HULQqf
d7XzQ1V/cP/nXDgEbeymGe2QSCeaJTY7h+++qG+vLEptsg+a6wHVMpUVkeml7iQB
Ijh3MsW0hYbY49xRRLdpWUx2zNJZEfbj5vxm0PGaR0UXLr3KLQOlnXH5DFn110uV
SjQuRfz0QQcWBsLrL079DmR1ojA4YbNl7N4ZhlHIP7dMJj4l4Cw3xwQ//Ub+o3NA
FptamzUPeTHVQxV8y418k0jT7gctMiaQyvhsuSog34aHuWZmyPqUOxjOp7Ib0OLV
lbn6CTED394ui1J2b5q4rDLiSZY2Ypw5UbYdlMrGMpIHjOB4OuoeqdLAEbyZ316H
hxATrzzdw7kNZJrYzugV
=E6qz
-----END PGP SIGNATURE-----

--kY7Q1I7FwGue0/xS--

--===============5837998748277611889==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============5837998748277611889==--
