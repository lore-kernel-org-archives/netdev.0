From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Sat, 07 Dec 2013 12:55:57 -0800
Message-ID: <1386449757.2195.30.camel@jtkirshe-mobl>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
			 <1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>
			 <52A36235.1040406@cogentembedded.com>
		 <1386440208.2195.3.camel@jtkirshe-mobl>
		 <52A3812F.4070701@cogentembedded.com>
	 <1386444985.2195.8.camel@jtkirshe-mobl>
	 <52A39129.7090507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-L2pE6Obm9FdBbYVVSxXW"
Cc: davem@davemloft.net,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56308 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755538Ab3LGUz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Dec 2013 15:55:58 -0500
In-Reply-To: <52A39129.7090507@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-L2pE6Obm9FdBbYVVSxXW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-12-08 at 00:20 +0300, Sergei Shtylyov wrote:
> On 12/07/2013 10:36 PM, Jeff Kirsher wrote:
>=20
> >>>>> From: Anjali Singhai Jain <anjali.singhai@intel.com>
>=20
> >>>>> RSS can steer packets based on recognition of all
> >>>>> sorts of different headers.  Enable some more of them.
>=20
> >>>>> Change-Id: I2264dedae66fb0bceca6fb6e772e050e3ca8efc8
>=20
> >>>>       This line has no place in the upstream patches, and I'm seeing=
 it
> >>>> in several patches of this series.
>=20
> >>> This is an internal hash id, so that we can track upstream changes ba=
ck
> >>> to internal git tree changes.  I did verify that this was acceptable =
and
> >>> is being used in the kernel in upstream patches before pushing this
> >>> information.
>=20
> >>      First time I hear about that. Its use is constantly denied in
> >> linux-usb at least.  Maybe netdev has its own rules regarding this tho=
ugh...
>=20
>     Greg KH seems to be persistent in being negative towards its use. I a=
lso=20
> react semi-automatically whenever I see it, asking to remove it. Anyway, =
it's=20
> really DaveM's issue whether to allow it.
>     The main issue with it is that it doesn't contain any useful informat=
ion=20
> to an ordinary person browsing kernel commits, it's exactly for the inter=
nal=20
> use only.

Well, I would disagree on the point that it would be for internal use
only.  While it is a internal git hash, it helps us support the Linux
community by helping us track the internal history of the patch for
support and changes.  So customers could give us either the Linux kernel
hash (in which turn we would find the internal hash id information from
the patch description) or could give us the I<hash>.  So you are right,
we would be the ones using the information to help support you and
everyone else.

Personally, the more information you can put in a patch description
(without writing a novel), the better.  While I was not originally a fan
of the "Change-Id:", the positives out-weighed any negative argument.

>=20
> > Take a look at `git log --format=3Doneline --grep=3D"Change-Id"`
> > You will see there are instances in arch as well as in wireless and in
> > other areas as well.
>=20
>     I saw only 3 screens of commits (expected to see more) without much s=
ystem.
>=20
> > So we are not doing something new or the only ones using this tag.
>=20
>     I didn't say that (in fact, quite the contrary).

Sorry, I inferred that from the response you originally sent.

>=20
> > Google appears to be using it as well based the following information:
> > https://gerrit-documentation.storage.googleapis.com/Documentation/2.7/u=
ser-changeid.html
>=20
>     Why should we care about what Google does?

I was just giving you background on where this tag appeared to originate
from.  I was not trying to say "Ooo Google does this, so we should
too..."

>=20
> > Places using gerrit:
> > http://code.google.com/p/gerrit/wiki/ShowCases
> > This is the largest example of a "Change-Id:" tag that I know of.
>=20
>     I didn't see the Linux kernel in this list, only Android.

Neither did I, but I did find the use of it in the Linux kernel before
we decided to adopt the practice.

--=-L2pE6Obm9FdBbYVVSxXW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSo4tdAAoJEOVv75VaS+3OxFMP/0cBKUt9YhZEcfmX+kuTffnz
h0MTfJ5j6Kvt0ZO9nSiTO/4LpAfzXLd/zRqPwow6NRIrq1Iadg09F3/PCoQcY+8W
RhtI70gx7OjMb+lsXBIuT48p+/MeOjUOpdQI6E/pNzC//Ed4aYF9q9Xk5tUij8e1
0ceS0IMJhUanSxIa02dtRy8Pp1dFKj1o00JU53kgcGOclPsFZe/7+MSvRvvzHPJp
f8jSyrdnYWKikUPCB/Z4cXiOBLLfcDLTFooCxezoY1lqrIY6QURrdKiWtJqn/2bU
pHmXEO9nUcgxtnN9r0/4ZVEUo8sVOnpGbNc41dTDyU/oEX5KH9u4OlsdCurpyDH/
Lm3Ml07U+SL2QyjVmZFbNsbP4M+TEc5gmqpO2z/HQZwXvX5PuykXG2W8+7GgEpAi
Z2cUDiM0SQo5WlHvaoUVXLfvHsUbzkee7vt5L1enyE29+Ya/ohA+lBVNGqdN0hjg
LFbB4KWadVUbOJxdMnRVuDJMhXfbFz/+jJK5wdUc7YxaoIAN5+oFzbkQYXaEBNDI
sN6BC7xSiywrN/jwOPBtklXPgqlDe4Mk6LL70Xq5u6dh1PgKsV9oiJNlt7nzivJ5
PP7XqLJWQVr+z7xckxC9PVZgVQcJwAGMpyJxrcu+gqh6LrhbsbyzXqGsYANqZ3gz
ztY14yLCCgNdrP1OgeE5
=968d
-----END PGP SIGNATURE-----

--=-L2pE6Obm9FdBbYVVSxXW--
