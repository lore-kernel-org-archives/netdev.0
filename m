From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] e1000e: Correctly include VLAN_HLEN when changing
 interface MTU
Date: Fri, 04 Apr 2014 15:22:41 -0700
Message-ID: <1396650161.2300.7.camel@jtkirshe-mobl>
References: <1396644528-32430-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-y38ApvfTN7aFzf/SNLjU"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35583 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064AbaDDWWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 18:22:42 -0400
In-Reply-To: <1396644528-32430-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-y38ApvfTN7aFzf/SNLjU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-04-04 at 16:48 -0400, Vlad Yasevich wrote:
> When changing the interface mtu, the driver starts with a value
> that doesn't include VLAN_HLEN.  Later tests in the driver
> set the rx_buffer_len based on the mtu.  As a result, when
> the user increases the mtu to 1504 (to support 802.1AD for example),
> the driver rx_buffer_len does not change and frames longer
> the 1522 bytes are rejected as too long.
>=20
> Include VLAN_HLEN from the start so that an user mtu greater then
> 1500 bytes is correctly reflected in the driver rx_buffer_len.
>=20
> CC: e1000-devel@lists.sourceforge.net
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Vlad, I will add the patch to my queue.

--=-y38ApvfTN7aFzf/SNLjU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTPzCxAAoJEOVv75VaS+3OB98P/0jxDNEVUAc3fm65fprONw6q
VDh8Hoa2itH2u5REFQvVHeyx6Wq90b0cGKZqyhGpFJ1sXh+joC34DxggYmXNrVLs
qIW1zVQRtQcsrDy9zy4+QQ2PDXJqFc3CUbgU2GwqxB/1Wtpxf8lLlt7/GRVtpkz9
5MIgCpBWSN99IsqUlvkCdHmuw2T7vjMPaIslW0/lFJMOVJUKsP9waoa8ozm48s6v
qXXuly1sj475tEpqiJOFaI73cOcJC/bSOW1/FW9QIoODZhLYXjNbfRYLJfWinKRC
Wz4Z+atmC7QlHC7tvgMgtZ+plHwy6/H72Mg3o8Ike+FykWKKtPCgJG1XpersH2D4
mZAyTqYDXGWnVBYmn45NY4UU5N8TKiWPQA5oQxZPeynViCjFn9IT7OI+Fd8oa/h0
X1ixWUOR1vkffdqGHxT6jUTPWb6x82T6z2yspF3svONrmRRQ53X0TyHBYk786UEH
BqrjO1a3zWlNi2TTuXtT3QDFCcSPKyPOKzA8PijuKXIt8vJj20/8FFnSHoxmbAVR
EU+4e2zYQWsHNXi5ahRhctyncdIg5FAEeQDFlIwaxnH0mBokkfYY83ignQC5DH+Y
3Hq1/EB/zfA6+TL/yK1a5VpnIocGB1PzTz4KK0/0vQaERPQXWFCdPZthGNzchgnQ
p/a2IysioBTlSpKkPk6i
=YclU
-----END PGP SIGNATURE-----

--=-y38ApvfTN7aFzf/SNLjU--
