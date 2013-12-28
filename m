From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 07/20] net: ixgbe: slight optimization of
 addr compare
Date: Sat, 28 Dec 2013 05:16:06 -0800
Message-ID: <1388236566.2183.191.camel@jtkirshe-mobl>
References: <52BE6CFD.4090403@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nJsXuLQrGhIQ/tJhlsLz"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BE6CFD.4090403@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-nJsXuLQrGhIQ/tJhlsLz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-12-28 at 14:17 +0800, Ding Tianhong wrote:
> Use possibly more efficient ether_addr_equal
> to instead of memcmp.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

Thanks Ding, I will update the patch in my queue with this updated
version.

--=-nJsXuLQrGhIQ/tJhlsLz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSvs8WAAoJEOVv75VaS+3OJUgP/ierLojo4L7lWwm7SkiQcc03
RVmLYhvrjayojyZI7eiYWzSujoB7uPjJuBCgeJ/J1IzCzDZ/UmIOZLsoM77zU9x7
0wtINZ5I+wRGIJ1IHBmqYtwEFk90Pb6fSZy3vnydgGSDMhA/D9gEWmUOxkDg5ygk
SgfGNUaBVxNyRU3uj/UA8WoKqDj87Ibsxvl9AangoUByvlGFVPgyQixe2Kzof4jw
ujeK7ooe1h9WVfqOfdIfuKegjyVmzmr3YFn1cyEIc6KjcOxDgDlmbWBCayykxKC4
4gLIOIEKQCZuBIc+TfkK14D/rehO1hVIr5YBvHUUSGqsDc8J+/aQsDn89vm3i05e
AFe+ww+Js7dOj0uzaeDchz07q7SKastYDBaoegrg77GXzNDlI4TNSMAMQN7Z/Ix+
fv1/CQ8wZo1pRBZFam6Cu516qA72/g7P9Aa+0wopiISUZ4zV3vM77KOCcMxwD24r
tKtmjdgk1anuIbnyX23OkUVOCEPivqNM0D3pK0dSNg4DhY0ls+izzJMR08295cR7
U15P1l/pT1ck/PTwuJcUEcM89IFOL7fK2Ix0KKKVdZJGLskAU15048gvp0Uqs4k7
3rXsNVIfQvwh9ocSDrkzwSNOdvyCu1FWvAzAL8eVDMLsigyhR3vK1kzp58Xdh0wI
3lilYwm4TlKM0L78+1eL
=TnP0
-----END PGP SIGNATURE-----

--=-nJsXuLQrGhIQ/tJhlsLz--
