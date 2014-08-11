From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] linux-next: Tree for Aug 11
 (net/ethernet/intel/i40e)
Date: Mon, 11 Aug 2014 12:53:06 -0700
Message-ID: <1407786786.2189.0.camel@jtkirshe-mobl.jf.intel.com>
References: <20140811155213.0aa083ce@canb.auug.org.au>
	 <53E8ECA9.6060806@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1Kh2MfbG97oYqtDz88Av"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux.nics@intel.com, linux-kernel@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <53E8ECA9.6060806@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1Kh2MfbG97oYqtDz88Av
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-08-11 at 09:17 -0700, Randy Dunlap wrote:
> On 08/10/14 22:52, Stephen Rothwell wrote:
> > Hi all,
> >=20
> > Please do not add code intended for v3.18 until after v3.17-rc1 is
> > released.
> >=20
> > Changes since 20140808:
> >=20
>=20
> on i386 and x86_64:
>=20
> ../drivers/net/ethernet/intel/i40e/i40e_fcoe.c: In function
> 'i40e_get_fcoe_tc_map':
> ../drivers/net/ethernet/intel/i40e/i40e_fcoe.c:354:23: error:
> 'IEEE_8021QAZ_APP_SEL_ETHERTYPE' undeclared (first use in this
> function)
>    if (app.selector =3D=3D IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
>=20
>=20
> Needs to #include <uapi/linux/dcbnl.h> ??

Yeah, Dave has already accepted a patch to resolve that, which I believe
went into his net tree.

--=-1Kh2MfbG97oYqtDz88Av
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJT6R8iAAoJEOVv75VaS+3OUcUQAKfxnygAOBA684idv3BxCkXg
eXgVT+6ip4/jzW9bSj4s9IQkNZafEK4IVfcJfDzEGbZEJkd2nUh/CI9jV5+l3Unc
SkCpMiws9LgH+jam2Uv5ZkPGMuHH30HstYcWFXCLcBXn+mbdxijKOx3wVj0eJBpX
6Ff+j+Blqx8uIuezSanFgOBeQI0mtbcmoCo5uPTXwPoKZXdzadq29IadGsINcYyE
Iirqco3MR+ih33MoqyjOM173SiOIDu+VuLr+F496oyCMyTIVpdK/+sM8V7oPgTAN
JWF9ZnvBbYdg0oVJrgIR6bNeariWrthEwV0BhIuTlaNHLB4hn32KzveAnp8ycwgZ
h46GKpC754BUcSXHC+TwrrZaHizpPR7anbTUejs6aGui0gLsw5Jkm6BaR3xM9yK0
tkjeAgIBxFzvgxpeObLNWdEhGPj+QF2QDyoIkf1ZL97ZKF3obieGb1PPmZM3KRvN
FdW6vVZlD8IAilpz6LqZ4P4az7g/w4Up6TteRP/a1KYYKg+sJDtc8hz16m6PJDRF
A1QZ8Rfi1t4hlxjuJsa2ShAyvYOhDuy2XWAnAEm5vyYw9YCNe5Rwosilpcoavv+5
QqjQAbCYcnlbnhOMMS6DgzMDoEW+SN8qy67U9WEeft/HZRKghUGhyOfb2OP/qAVt
UiCOZw0K6WvaOy90GvDd
=aq7b
-----END PGP SIGNATURE-----

--=-1Kh2MfbG97oYqtDz88Av--
