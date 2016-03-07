From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 01/12] internal.h: change to new sane
 powerpc64 kernel headers
Date: Mon, 07 Mar 2016 15:53:55 +0000
Message-ID: <1457366035.15205.11.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-2-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DF7e/4XH+bdg3SPN4n6M"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43581 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752913AbcCGPyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 10:54:10 -0500
In-Reply-To: <1457138533-2417-2-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DF7e/4XH+bdg3SPN4n6M
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
[...]
> --- a/internal.h
> +++ b/internal.h
> @@ -3,6 +3,13 @@
> =C2=A0#ifndef ETHTOOL_INTERNAL_H__
> =C2=A0#define ETHTOOL_INTERNAL_H__
> =C2=A0
> +#ifdef __powerpc64__
> +/* Powerpc needs __SANE_USERSPACE_TYPES__ before  to select
> + * 'int-ll64.h' and avoid compile warnings when printing __u64 with %llu=
.
> + */
> +#define __SANE_USERSPACE_TYPES__
> +#endif

This is also true for several other architectures so let's define this
unconditionally.

Ben.

> =C2=A0#ifdef HAVE_CONFIG_H
> =C2=A0#include "ethtool-config.h"
> =C2=A0#endif
--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-DF7e/4XH+bdg3SPN4n6M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3aQTAAoJEOe/yOyVhhEJJzEQAM1peBSoHNV27jXk1yAVd+Kp
BhzYCvnrBLwQg6o/14A3g0r2IXoyziQmUQeMzamHGxuShQiaJV1A3j71+AXTmLj6
x05zHWnQRYLzEspUMn5Zv0eeFEvHfIwGjQGfeF4R6qKEJbt+9TlHXyYKqkaZU+Ba
Z4g17ImsW08fJfSMgn3Mg8pj/VhKMUEvNMQAOkerX/wbt/X3B34ifuzEy4I4SQOL
CRHu1MTqwXXMGB6za1DxHDBRaIXahwaKv4ev/u/MVmqo+lBjH1mzUk4feU9GJinp
oIOXYMmFtZ6WfQ4/mARUaX5pqgRSZdYQSMPcNf7m05f7Ug8VVU1oC18Z0dNx6bDG
F+4WZ7fXFUx2kSUyUDQl0IS/PnM2eCkAJwGyLEXN+GEkjzdVPWZIxqjdfJhEOeo/
OeQ3GgLhzbXTgRy01SRqfByXa4f5xHjZRXEuofVlSXZ8aJ1m5Gm3Tf7cz8Ry02cw
GQebJi+b8EsfBX6FB6zT+Y3vGfWgiUp3WFzj4HenGB1RgMDH4BHO654Ka/gXKwLQ
+8fh+nynsgQ1yNWbpXohh/uSMljzXXrhWR3Iqs3oNWxWAgtQvNoJvJK8sZHLwIyl
qSFfeNzE6m4TAf4Udbme1a5wBhTQgWqNWoLwCHdjwLi0dfiSoFPmyNum1OdTx84B
hG8mqkdkriNwDNc3YvLv
=4vbY
-----END PGP SIGNATURE-----

--=-DF7e/4XH+bdg3SPN4n6M--
