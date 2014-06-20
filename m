From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/13] i40e/i40evf: i40e_register.h update
Date: Fri, 20 Jun 2014 02:57:48 -0700
Message-ID: <1403258268.2295.66.camel@jtkirshe-mobl>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1403250588-14356-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <87a998q78p.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tYZjD0iEUxODX0o/W/Ji"
Cc: davem@davemloft.net,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4957 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966220AbaFTJ5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 05:57:51 -0400
In-Reply-To: <87a998q78p.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tYZjD0iEUxODX0o/W/Ji
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-06-20 at 11:07 +0200, Bj=C3=B8rn Mork wrote:
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
>=20
> >  drivers/net/ethernet/intel/i40e/i40e_main.c       |   30 +-
> >  drivers/net/ethernet/intel/i40e/i40e_register.h   | 5011
> ++++++++-------------
> >  drivers/net/ethernet/intel/i40e/i40e_type.h       |    3 +
> >  drivers/net/ethernet/intel/i40evf/i40e_register.h | 5011
> ++++++++-------------
> >  drivers/net/ethernet/intel/i40evf/i40e_type.h     |    3 +
> >  5 files changed, 3728 insertions(+), 6330 deletions(-)
>=20
> Not really a comment on this patch, but the diffstat above made me
> suspect that you have lots of duplicates here...  Does it *really*
> make
> sense to maintain syncronized copies of these rather large header
> files,
> just because a total of 3 lines are different (not counting the
> unneccessary header diff and the assumed unwanted whitespace diff)?

We have been discussing this internally to come up with a solution and
one of the big reasons why we have not made the common code into a
shared resource for both drivers has been due to regression issues.  But
we are currently actively looking into what can be done to minimize this
type of duplication.

--=-tYZjD0iEUxODX0o/W/Ji
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTpAWcAAoJEOVv75VaS+3OGU0P/j+B9UNlZwbvG3wWZj88cR85
beaybp9adLW+i8saInMC8RFFvP+guZqDX19xoyMrPAuBj3w4eWoyxG+Zy62aCH7C
JLkZ6PAkPXpBloKUyFx6VgbypjI7qftfm3r06FtfSPnuRg9vsZTqWOErJDcd5Rok
iIbcAqhEfMYXd+UTTq8IG11U9pNIQcWmRFtzSuTo2mYOojtSL/bX+SB6g+SlIFLh
9Sxo7k03b1J6QI3WTL2byg/ovey9ENsAwF8J2Dysj9rP1eKu209yD7H+cDbp0JWj
BUYCXV6vHVQYKOVK7kJAif93nL/y91a7jBBSkZa+67UdPtLxuZNeeeAVDOx5NSly
w976F12g+BaxZa3FLv4SxWyVmDl7HgozpNt+EDL6BPqBe8dqLK9Z/eDAjTzea4+Y
huKvQ4zGDoZ4U+muOBY+FKKGKBguFu6CwBNgbGaaTE38kF6mYsy6Rmc8VCHuzBu1
/LtyT3LBos67ytpY2AXck4LCmqyEPFbqblVQQp0VMUu3ftr4TSHMNw77Ce/qmeci
BUF8fBWsmiCZYsTk+dEkfZbSrOP62nLqRgtiER6LLVRL+ksrLNSeyPUwY/ozh6dk
8+uKKsUk0PZ1qETD60viZbq9g3KXc4D68CmdNg1iql46gM9KH54H2N6QHoo8L9as
wAYxuZhebGcT/m1yDZJf
=MLgm
-----END PGP SIGNATURE-----

--=-tYZjD0iEUxODX0o/W/Ji--
