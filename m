From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Thu, 4 Apr 2013 10:15:34 +0300
Message-ID: <20130404071534.GC30287@arwen.pp.htv.fi>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
 <1364993634-6378-2-git-send-email-kishon@ti.com>
 <515CC123.4060402@wwwdotorg.org>
Reply-To: balbi-l0cyMroinI0@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5015946729000906689=="
Cc: broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org, mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org,
 Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>, javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org, cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org,
 eballetbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, sylvester.nawrocki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <515CC123.4060402-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
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

--===============5015946729000906689==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KDt/GgjP6HVcx58l"
Content-Disposition: inline

--KDt/GgjP6HVcx58l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Apr 03, 2013 at 05:54:11PM -0600, Stephen Warren wrote:
> struct phy {
> 	struct device *dev;
> 	struct module *owner;
> 	int	(*init)(struct phy *phy);
> 	int	(*exit)(struct phy *phy);
> 	int	(*suspend)(struct phy *phy);
> 	int	(*resume)(struct phy *phy);

I wonder whether it makes sense to provide ->suspend/->resume callbacks
here. We already have dev_pm_ops providing those methods and we can just
wrap pm_runtime_* calls to be called by consumers.

--=20
balbi

--KDt/GgjP6HVcx58l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRXSiWAAoJEIaOsuA1yqREFXkQAIP3OrjLQw12ylU/UHkhNtSJ
B9qlFZyTCIGB0Vt9B3LZj5E3Vr7+GjR6UVbgC4FrYGJ57kFM7bzF/s+4r/8IjHzQ
OrVRwpQButjAQZ6AgOd3rWMl2GvV60Eq6qlaWxWnjYLlzyBon1ThFPcOqBwDXaxi
FwADvC1Yi1RqPDyvAUz+awgwZI11F4PRv+CQtf2kzDrbSdyrM64IykFGzhe9SrMJ
50A6YUZ2DSniypLc53dYFgaLQSatCBPVT5MAMrvGABE7XyiAN4WHYpWco75FfaM2
/FGsGfp2JBewuWYOV/M2ARnE8YVYYMQYaBMlf1i0wdFmW4VWRbcRYeMPAKpjAOJn
QLfhRyfDUeKb8L6IZxRLHo0LnF3UUXy27EmtZBAFGXDa2fTIieJSE1KE3nR9K9CF
AKFdNwBxW54Z/FBn9atxJQzZcWaoVkp3iQhdZK3Nqhg5k5AaO5eZssm+YEPRMiZ0
yjSintNTJDLR1JCwX6f4fgXgPhrKt48y7XdReHpeqFPZVnSCB4W+Y4STHI4sw6N8
975ACZvbnw5NA+FpNwrBxcwsyQ7CdodsLsRDDlRrKRlu3jedXy5dhtIVu9Q7bCNn
g5DK/nQ7mrVAZMpGN240eAdZszGR78RgZAL7+90YcoKJT7Kns667clNN2giJ6Tn9
QbXnLOdkrSFA1+UF2k8E
=jF/V
-----END PGP SIGNATURE-----

--KDt/GgjP6HVcx58l--

--===============5015946729000906689==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============5015946729000906689==--
