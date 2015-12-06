From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH RESEND] fm10k:Fix error handling in the function
 fm10k_resume
Date: Sat, 05 Dec 2015 23:35:07 -0800
Message-ID: <1449387307.3198.22.camel@intel.com>
References: <1449369415-22303-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LlzK4HfJHakGJ7xwCOCV"
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52616 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbbLFHfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 02:35:09 -0500
In-Reply-To: <1449369415-22303-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LlzK4HfJHakGJ7xwCOCV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2015-12-05 at 21:36 -0500, Nicholas Krause wrote:
> This fixes error handling to proper check if the call to the function
> fm10k_mbx_request_irq has failed by returning a error code and if
> so return immediately to the caller of fm10k_resume to properly
> signal a failure has occurred when accepting to resume this network
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> Tested-by: Krishneil SIngh <krishneil.k.singh@intel.com
> ---
> =C2=A0drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 4 +++-
> =C2=A01 file changed, 3 insertions(+), 1 deletion(-)

Don't bother, David Miller has spoken and will not accept any patches
from you. =C2=A0So even though this was not properly sent to intel-wired-
lan@lists.osuosl.org, which all kernel patches need to be sent to, I am
dropping this patch since David Miller will not accept ANY patches from
you.
--=-LlzK4HfJHakGJ7xwCOCV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWY+UrAAoJEOVv75VaS+3OwlwP/3CxTmfLW0N4Cq/DFQui9Z69
YSgFTSSeULPlgQ3+iESok0lJtrQLEE2eXAwbHUwx0iwD+gGaVtKg2v3H6eRAAvgd
7oW29WrC5bOkSaPJysGl8eWUrIyWZuCUq8ae6x6LyJh1O76BakUGNBsqp03Iqw5f
gLojwAyMr2qW9AfYZEomXgz1QqYBRVZQcGt1fNbvloG1QIwYDXSpli0I/QL+3qlY
aJaHmHfaE4FcPPIfnIK7bHdXkBTd832NTXYyPNdne5urwgJLgc666qxrijzKvEl2
u3iyqJwIEQLOgsahNPw4o6VpuWvnGMC1NoGfgmScBrX8+7p42NlWpRfNOaIo6C2M
jWKndo45HvZMYmRXJMT03Itn2vnv+4zSLuhWArgwBOXnyhwEhfUEDytS6vOpC2nG
Vy/iEuuIym1IGZIhzWw7/puV7HZWHCZttbcNVbAWmNecOVO/m0mzYLRnhxMxTbnG
vMG0bz1siLbh1bJ7COJqO2vr5FGCy5tdI25XXStHMLRq/dE2/e/ZaVkvYaoPv90c
B9SiXig13WLSUIkyEkU+FT/azSOFH6iRZNPpcrLy6co7kDXFet62ZHi+35KChk4q
UIQYelghkOuy+zC5fNrAQtxGpE0JbwPt4oxHeA/pd6PXM+Cy8SbXFyjkUVVsD7J7
vmfdNsHJIGPOM6CcljGs
=HeUN
-----END PGP SIGNATURE-----

--=-LlzK4HfJHakGJ7xwCOCV--
