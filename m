From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2 net-next] e1000e: Move pm_qos_req to e1000e adapter
Date: Fri, 10 Apr 2015 08:59:27 -0700
Message-ID: <1428681567.2729.90.camel@jtkirshe-mobl>
References: <cover.1428672434.git.tgraf@suug.ch>
	 <5c4f0f5fc93592d2b4bce2cd7dd494a52a2e19f8.1428672434.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ivY0M+Ido7KiWwJxk5Xt"
Cc: davem@davemloft.net, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	daniel@iogearbox.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59962 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754809AbbDJP72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 11:59:28 -0400
In-Reply-To: <5c4f0f5fc93592d2b4bce2cd7dd494a52a2e19f8.1428672434.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ivY0M+Ido7KiWwJxk5Xt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 15:52 +0200, Thomas Graf wrote:
> e1000e is the only driver requiring pm_qos_req, instead of causing
> every device to waste up to 240 bytes. Allocate it for the specific
> driver.
>=20
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/e1000e/e1000.h  | 1 +
>  drivers/net/ethernet/intel/e1000e/netdev.c | 8 ++++----
>  include/linux/netdevice.h                  | 1 -
>  3 files changed, 5 insertions(+), 5 deletions(-)



--=-ivY0M+Ido7KiWwJxk5Xt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJ/NfAAoJEOVv75VaS+3OVDsP/2VTi9Os3SNA0HiIfb4wSkKV
YYNkkxzH0tL7cD8Dl5WbxXqzFNC5V15M5jT0iFd5lxL9hfK9WxqXkcnbGeu17/a4
g98GU4yX9ahqASaGfv5QWcf0VWFbU+bfHdUmJ5R7vsVKVadHraEevIKoB+DC6bvk
AaRVrEXsidHTTSPRBYGqt/hUSiX/p1hq7YhmhnxrGl7P62TMdSjC7lP5x+IH1y/T
dMh5lrWZDjSgWCS7YtDxdzrGdz/Q9CkeqB3LQY2pU/e8NFYjbFQYj6lum1V232ml
n5Ooi8N8sYbtS83rPCoXPujxq64U/J5i1L/RnUqF6vS3+aRgjXANlSb/tD2TXjlo
/cRNu47NJMUwekFbi/Cm1S/QAjaqwbZf2xKNACrd3ZIOzPpqoAnhSY2jJEXYxrTX
uG25oUtBoFYwTCdo0GWVYYfmOlbee677drnt5FgcDpLgnZQzymj8Y+nXTxY32XmU
2homRDN1t5FoseTjhiyE6ESr2cjZ0e8g5p2vcRwnbOBkLdErCpftQ+1/O1d17PCM
7XSnoCKbsZEg8TrzQTmn6cr3Go/IpZqtW/CRyI/p+pCb877X2zhP3ojFNXrpkTZs
+7Cy8kLSpj+CEUndTGVCj9MR5AAfExWzMmOIVeB8/AQ+3k3WD4IXwTxjjY0n0FGC
XF3HFKM87sLpcZ1zBh/c
=iloQ
-----END PGP SIGNATURE-----

--=-ivY0M+Ido7KiWwJxk5Xt--
