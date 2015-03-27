From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 0/2] ixgbe: Add the appropriate ethtool ops
 to query RSS indirection table and key
Date: Fri, 27 Mar 2015 03:05:51 -0700
Message-ID: <1427450751.2497.65.camel@jtkirshe-mobl>
References: <1427409886-20261-1-git-send-email-vladz@cloudius-systems.com>
	 <1427429878.2497.46.camel@jtkirshe-mobl>
	 <551528B1.90303@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-khaDe438Ct3kI+/xmPl/"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23335 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751578AbbC0KFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 06:05:53 -0400
In-Reply-To: <551528B1.90303@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-khaDe438Ct3kI+/xmPl/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 12:53 +0300, Vlad Zolotarov wrote:
> On 03/27/15 07:17, Jeff Kirsher wrote:
> > On Fri, 2015-03-27 at 00:44 +0200, Vlad Zolotarov wrote:
> >> Add the ethtool ops to VF driver to allow querying the RSS
> indirection
> >> table
> >> and RSS Random Key.
> >>
> >> This series refactors the RSS configuration code to store the
> current
> >> contents of
> >> RSS indirection table and Hash Key in the "adapter" struct so that
> we
> >> won't need
> >> to access registers every time this info is queried.
> >>
> >> New in v2:
> >>     - Some styling fixes.
> >>     - Moved macros definitions from ixgbe_type.h to ixgbe.h.
> >>
> >> Vlad Zolotarov (2):
> >>    ixgbe: Refactor the RSS configuration code.
> >>    ixgbe: Add the appropriate ethtool ops to query RSS indirection
> >> table
> >>      and key
> > I am assuming that this series is to replace the latest v8 series,
> > correct?
>=20
> This series is a precondition for v9. I have prepared it and waited
> for=20
> this series to get it... I'll send it on Sunday.

Ok, so I will drop v8 since there will be v9 coming.

--=-khaDe438Ct3kI+/xmPl/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVFSt/AAoJEOVv75VaS+3OaOAP/0OLBS4PbUvF9yKXzJMIZLzG
XNu4r5b7GOknUDjAGwN+P7fnSwurhIX1CHRQvjjR31Ub6E9DqR9o6yJhpJTq/5BQ
u91EpLH45ynj9GyqAljKgbFfi5W6kRFHnCchyzlJ+Yso4f+wQwm4BT7YIb9xT0lZ
xjobKgCLrMyK3ajda6vDMQQf/rv2UzkW/LlS0Q3B7jSDLFtOkjZxgiT4WsvUeqxj
dIkBqRisro4I0CZ7p/7aaXMVHBJ/IsvB4PrvfXFvXmaSrxYIjPB8ngqf/xEzJdWO
6U9QTjgw1r+r2/2l4QVsmEMG6l0xk6NQOIqcGfgPz7FPgQVzzkOUitzPAET5+bKY
ik4XkeLbBkVyO8pLRTkixwa5EvnwFBIAd4Hs4CX9yyMpN7RB77v3VwcuHYZV/Wnq
QztlfQnQgvSJlgNyItI8GfTxdv6ctPTRntjw3kdG01ERzvXRBIcshS0/3yQP1QMX
PtTXnHtY/T4KxC1b4NkfUd20ajfD0eij8rUSAL13xqIWTeFkatVSWyjRHIDSTLcr
+/+PF1aoCk8DaItp+/U1NleS2z05ptfeGFnVbrKGh4vXIx2187Q0N+kiAeO99Lq7
TcIc+v4yytOCwNV0zGVSOO8k9sG5/mhEkVOnHfd8WTjjy7dS9q1UE2HT35dkgGr5
kVni8oHNX8XGrWYpf2mv
=zUOr
-----END PGP SIGNATURE-----

--=-khaDe438Ct3kI+/xmPl/--
