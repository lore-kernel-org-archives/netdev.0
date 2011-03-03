From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: fix race condition while driver unload/reset
 using kref count
Date: Wed, 02 Mar 2011 17:56:41 -0800
Message-ID: <1299117401.2781.6.camel@jtkirshe-MOBL1>
References: <1299091597-28409-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Zstr3MsmP3d3KnDb+gFK"
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "prasanna.panchamukhi@riverbed.com"
	<prasanna.panchamukhi@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28885 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756952Ab1CCB4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 20:56:43 -0500
In-Reply-To: <1299091597-28409-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Zstr3MsmP3d3KnDb+gFK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-03-02 at 10:46 -0800, prasanna.panchamukhi@riverbed.com
wrote:
> This race conditions occurs with reentrant e1000_down(), which gets
> called by multiple threads while driver unload or reset.
> This patch fixes the race condition when one thread tries to destroy
> the memory allocated for tx buffer_info, while another thread still
> happen to access tx buffer_info.
> This patch fixes the above race condition using kref count.
>=20
> Signed-off-by: Prasanna S. Panchamukhi
> <prasanna.panchamukhi@riverbed.com>
> ---
>  drivers/net/e1000/e1000.h      |    2 +
>  drivers/net/e1000/e1000_main.c |   41
> +++++++++++++++++++++++++++++++++++++--
>  2 files changed, 40 insertions(+), 3 deletions(-)=20

Thanks Prasanna!  I have added the patch to my e1000 queue of patches.

--=-Zstr3MsmP3d3KnDb+gFK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNbvVZAAoJECTsCADr/EWUyDIH/3q8jtLOsa4buoFjN0kXto3T
lMnV37skEBkwNZrHykQ7HS+S0p8/S4ZbKZLDIbBebvnBnQDFM1dD6gRGF1YxEc1/
Az+bXILYdKfCg0HIMF3kL40YT4itynyqw23DdZAc7XV10zHGamAdcg2YzRZDVJto
LdIOO000SWDDeYywJxdznPyyr+3ughC4X1GQFWDflVXN+lygDk86jY2zNtguas4k
iKvRnR5ChQbDznsG/k0hi/sqD4XdcLcvwP2Ve48TVgDuJk/3AtK8ST9r/QhZUrMn
QnHhIr0fuJZl66dHb/pi+P8UkF2/wKA8/vUNjikSSpddsXH6NPavBSHbwS0pHYk=
=aPHa
-----END PGP SIGNATURE-----

--=-Zstr3MsmP3d3KnDb+gFK--

