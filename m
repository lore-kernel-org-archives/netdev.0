From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 02/29] wimax: headers for kernel API and user space
	interaction
Date: Mon, 08 Dec 2008 21:05:34 +0100
Message-ID: <1228766734.22164.127.camel@johannes.berg>
References: <cover.1228759689.git.inaky@linux.intel.com>
	<b0c3e76927519e8e46f9de8927207257159a70f0.1228759689.git.inaky@linux.intel.com>
	(sfid-20081208_201008_047825_51CAB747)
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1056465439=="
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <b0c3e76927519e8e46f9de8927207257159a70f0.1228759689.git.inaky@linux.intel.com>
	(sfid-20081208_201008_047825_51CAB747)
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org


--===============1056465439==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-SjvimS/4gdAVP6+kjO6X"


--=-SjvimS/4gdAVP6+kjO6X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-12-08 at 11:09 -0800, Inaky Perez-Gonzalez wrote:

> +/*
> + * Generic NetLink operations
> + *
> + * Most of these map to an API call; _OP_ stands for operation, _RP_
> + * for reply and _RE_ for report (aka: signal).
> + */
> +enum {
> +	WIMAX_GNL_OP_MSG_FROM_USER,	/* User to kernel message */
> +	WIMAX_GNL_OP_MSG_TO_USER,	/* Kernel to user message */

Since you're going to do these iwpriv-style things anyway no matter what
I say :) can we at least get it to use netlink attributes *within*
these? In i2400m you define a new protocol that pretty much looks
identical to netlink attributes, but just a bit different:

> + * This is the control protocol used by the host to control the i2400m
> + * device (scan, connect, disconnect...). This is sent to / received
> + * as control frames. These frames consist of a header and zero or
> + * more TLVs with information. We call each control frame a "message".

Or isn't that what is contained in the WIMAX_GNL_MSG_DATA attribute? You
can nest netlink attributes, that would already make it a whole lot more
regular, rather than defining your own sub-protocol.

johannes

--=-SjvimS/4gdAVP6+kjO6X
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJPX4KAAoJEKVg1VMiehFYVBIP/3onRoAkpgEjc/bnJbGnUk1H
D7EmKCRlSuKkuW8vz0NQ1IiAwVDqPDnTYGfsHHC6JzxCxIfgtLrnpg8faOw0ZIP6
zbogJcM1vDivFAX2fFLJQ0lDZ9jXiDO16d6QPOUCUYtNQzEAc7uuUjp3A/yFN9EW
l3Ww3YWhRDQ1zBx+cIxDmlzlyGnb3sUhZQPqQG9CFpqkCQTg/V98vto/k02v721c
w3OPHtAy1g+Zl4YqrgVX5LWrrYwxn5R6GWWMZkjUZUdaHDZ7m3L46/QyFgMu/cH7
SZcsl6+EQZ0A58nAsy9kTBu3G20Bc5uxoqR2KGmhvuDA5QgUoo2jNBjuHVGPxM3D
tXZmSjlB56zcnO4I9VbDOsiPZJBu9Rca9LkA0U3G/2nVwYUDMviTM1vA/R+BWUjE
T389BTspOI24/U/c/swodKrTZzJ6DnQXRG65byprsBL3HNsDa+ih7MLUS1YOvAyo
DS0H05w5Zs26g2AXL0GMxARH8jZCw4x6CSMwaa/vXtQS29mA+y80BhKPAH003m2S
Ic8SNS9AvGRXj43fIQhrQ5X1eJP2GwlTOVnCOSUTSBkJW5+hvb6BvlDU4srqAusd
9U5bbeXCNid9R/kEBAlG1J8J20+OnJJI/07DdpnL0yuo/skYxgmfCsWGnLxT7dbH
fGzYUfmK8tKseGXVtfDw
=RGmj
-----END PGP SIGNATURE-----

--=-SjvimS/4gdAVP6+kjO6X--


--===============1056465439==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
wimax mailing list
wimax@linuxwimax.org
http://www.linuxwimax.org/mailman/listinfo/wimax

--===============1056465439==--
