From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH v3 1/4] net: Add support for hardware-offloaded encapsulation
Date: Fri, 07 Dec 2012 15:15:15 -0800
Message-ID: <50C27883.5010006@gmail.com>
References: <1354845419-22483-1-git-send-email-joseph.gasparakis@intel.com> <1354845419-22483-2-git-send-email-joseph.gasparakis@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigF3C70E2C80243DFE9C2B2699"
Cc: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	gospo@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dmitry@broadcom.com,
	saeed.bishara@gmail.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354845419-22483-2-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF3C70E2C80243DFE9C2B2699
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/06/2012 05:56 PM, Joseph Gasparakis wrote:
> This patch adds support in the kernel for offloading in the NIC Tx and =
Rx
> checksumming for encapsulated packets (such as VXLAN and IP GRE).
>
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  include/linux/ip.h        |    5 ++
>  include/linux/ipv6.h      |    5 ++
>  include/linux/netdevice.h |    2 +
>  include/linux/skbuff.h    |   90 +++++++++++++++++++++++++++++++++++++=
+++++++-
>  include/linux/tcp.h       |   10 +++++
>  include/linux/udp.h       |    5 ++
>  net/core/skbuff.c         |    9 ++++
>  7 files changed, 125 insertions(+), 1 deletions(-)
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>


--------------enigF3C70E2C80243DFE9C2B2699
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJQwniDAAoJEOVv75VaS+3OuOQQAJyWSm2sPtM85zbKVitTi3LK
SmfVWnuE936WftqO0tQqmUjU67sdnTvAD/AAsc2uetvEhNG9s8o4WSSSNClh+0JR
Ir/N6R3Pit+bRmlfOCtnN7h7zIh7Vr8cbAX0GUUy6GnudUY5EnCPDWhLw3IcENfW
UEV7N1yUg1fYtB1dWG0BvOF2FNuhiiROVVeAKod8DNiwe5I3N64VhAW3SrZjMM/p
iJFLev+NgOQM+oXOJM6VQAi8ftz24pgdlsq/MlvwbfL8BxRtetbmHqNby0fm84lR
kMHAriol5W67DQ0iUW/0vbuMaGKFe46PJPB9kdPY3clXFbaNV7neyaaF7oMMT9bh
uh5xmo4/HhHc0Bvz4DaAsozI5dmUT9LFl0D3nbsBhQlp0CC5ZUWhx1Rkg9hjjW+5
Ju+tuo9GSRNQj0+/hW2qG68r8EDaGxObRD110VY/K16L40dY5EGFIiflx6ToFV7v
sa/BRxHzslNS89mM5/q2q9KNLr+Wrpl7bAF8SgpQ0ufJy4wlAe33cEFZe+N9dxl3
Hh7XHCFkL9it5TX0inzJjB5H9f+A/ouvmFXyMh5pEShaLiD+x9/cWrhMRIivEuwu
Siu9lF+HVFexr8qgEZ0OF8QQOtsZOluq6TKjM3yRXicESjJp7DWsRauYlJJGHC5W
U0naHbf7n+ecx7ARYDku
=6VCR
-----END PGP SIGNATURE-----

--------------enigF3C70E2C80243DFE9C2B2699--
