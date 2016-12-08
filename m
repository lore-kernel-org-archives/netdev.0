From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH net-next 2/2] net: ethernet: Initial driver for Synopsys
 DWC XLGMAC
Date: Thu, 8 Dec 2016 22:57:12 +0100
Message-ID: <20161208215712.GB12472@amd>
References: <cover.1481075763.git.jiedeng@synopsys.com>
 <3fe82457c51f8437797eae27d03cdb0dcbef039b.1481075763.git.jiedeng@synopsys.com>
 <20161207094815.GB5399@amd>
 <bea5ea07-cbab-35fe-434c-1cfcb96225ef@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="UHN/qo2QbUvPLonB"
Cc: davem@davemloft.net, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, CARLOS.PALMINHA@synopsys.com,
        lars.persson@axis.com, thomas.lendacky@amd.com,
        peppe.cavallaro@st.com, Joao.Pinto@synopsys.com
To: Jie Deng <Jie.Deng1@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <bea5ea07-cbab-35fe-434c-1cfcb96225ef@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--UHN/qo2QbUvPLonB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2016-12-08 13:58:47, Jie Deng wrote:
>=20
>=20
> On 2016/12/7 17:48, Pavel Machek wrote:
> > Hi!
> >
> >> This patch provides the initial driver for 25/40/50/100 GbE
> >> devices using Synopsys DWC Enterprise Ethernet (XLGMAC)
> >>
> >> Signed-off-by: Jie Deng <jiedeng@synopsys.com>
> > I trust this is different hardware from stmmac?
> Yes, different hardware. Currently,  Synopsys has several Ethernet IP cor=
es. But
> drivers for these hardwares are scattered in different places. I really h=
ope
> that they can be centralized into driver/net/ethernet/synopsys for mainte=
nance.
> This makes things easy for others to find the corresponding drivers.
>     - QoS
>         drivers/net/ethernet/synopsys/dwc_eth_qos.c
>         drivers/net/ethernet/stmicro/stmmac/         =20
>     - XGMAC
>         driver/net/ethernet/amd/xgbe/
>     - XLGMAC
>         No driver for this hardware in mainline at present.


> >> diff --git a/MAINTAINERS b/MAINTAINERS
> >> index 331f6af..738f818 100644
> >> --- a/MAINTAINERS
> >> +++ b/MAINTAINERS
> >> @@ -10639,6 +10639,12 @@ S: Supported
> >>  F: Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> >>  F: drivers/net/ethernet/synopsys/dwc_eth_qos.c
> >> =20
> >> +SYNOPSYS DESIGNWARE ENTERPRISE ETHERNET (XLGMAC) DRIVER
> >> +M:	jiedeng <jiedeng@synopsys.com>
> > Jie Deng here?
> Oh, should be Jie Deng here. Thank you!
> >
> >> @@ -0,0 +1,228 @@
> >> +/*
> >> + * Synopsys DesignWare Ethernet Driver
> > Your patch title names hardware differently...?
> Yes, currently, it should be XLGMAC driver. I extracted the parts can be =
shared
> for different Synopsys IPs.
>=20
> The XLGMAC driver can be divided into three parts
>=20
> - The DWC ethernet core layer (DWC ECL):
> Currently, it supports XLGMAC. But I think this part can be shared for di=
fferent
> Synopsys IPs.
>=20
> - The DWC MAC HW adapter layer (DWC MHAL):
> This part was designed to include special support for a specific MAC IP.
> Currently, XLGMAC, and I think we can add
> something to support XGMAC and QoS in the future.
>=20
> - The glue adapter layer (GAL)

Ok, thanks for description. Hopefully it can be merged in a way that
is not too confusing...

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--UHN/qo2QbUvPLonB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhJ1zgACgkQMOfwapXb+vI2ggCfRcIFc+DddVZKoMlRiimmHTsy
R4oAoIR35llQvE8/3GSZRgXrg/K8Mfup
=z/sd
-----END PGP SIGNATURE-----

--UHN/qo2QbUvPLonB--
