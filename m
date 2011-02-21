From: Jeremy Eder <jeder@redhat.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Mon, 21 Feb 2011 14:31:40 -0500
Message-ID: <1298316700.2768.687.camel@jerms-wks.usersys.redhat.com>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
	 <1283356463.2556.351.camel@edumazet-laptop>
	 <AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com>
	 <20100901.183251.106803238.davem@davemloft.net>
	 <1298312395.2608.65.camel@bwh-desktop>
Reply-To: jeder@redhat.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-mewGJBXfnMaMaQbEt/PJ"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197Ab1BUTbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 14:31:41 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p1LJVf5s003953
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 21 Feb 2011 14:31:41 -0500
Received: from [10.12.64.35] (dhcp-64-35.rdu2.redhat.com [10.12.64.35])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p1LJVeKw008952
	for <netdev@vger.kernel.org>; Mon, 21 Feb 2011 14:31:40 -0500
In-Reply-To: <1298312395.2608.65.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mewGJBXfnMaMaQbEt/PJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-02-21 at 18:19 +0000, Ben Hutchings wrote:
> On Wed, 2010-09-01 at 18:32 -0700, David Miller wrote:
> > From: Tom Herbert <therbert@google.com>
> > Date: Wed, 1 Sep 2010 09:24:18 -0700
> >=20
> > > On Wed, Sep 1, 2010 at 8:54 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > >> 3) Eventually have a user selectable selection (socket option, or sy=
stem
> > >> wide, but one sysctl, not many bitmasks ;) ).
> > >>
> > > Right, but it would also be nice if a single sysctl could optimally
> > > set up multiqueue, RSS, RPS, and all my interrupt affinities for me
> > > ;-)

Are cgroups the right place to have the network stack pull "guidance"
from ?

If an app is bound to a socket/core/NUMA node; then the network stack
could inherit the cgroup's tuning and adjust kernel knobs accordingly.

This would not replace procfs tuning, but it seems like a natural
extension of how cgroups and RPS/RFS/XPS could be integrated to ease the
management burden that these new technologies might impose.

--jer

--=-mewGJBXfnMaMaQbEt/PJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJNYr2cAAoJEJqn3Wey3P5nZaoP/17Ts6xr694cq6sxqJ1X7qfW
UyWJtevKbiqQ0XSMgYIyQnK+SluXZtXPqYzyu0MjK8nbOr6JWgiA79JlwamErIto
BpAUWimStZc+IloNZp5UTr3dyawOFkw7TL+kEHC7fnnFo25MVeonv2a/ThN5ZfhJ
/ka547H4R5UOZT15zBQ+v0o/a5yVmNJS13JL7ccq2NuXBAMSOAsHczeeNX9sUURK
bMJRzctoLuYEEl05IlZ7IySud8R7bWAQ5zwjqTeljFksoOBxNYK4sJUIv6NhnvhK
xrrhulQ0jhCdyEAIrRmlagPUWR+ADMjVTLxrYGSNGBRzcMfvWDyRQ73vUqXObb5V
Qve4QD0RpsN/0w/CFy9UVzW56oacM+H2Jb7AAHR636hmjAiFihjabBLu0hqyHFEd
5XWp2j38s2UhsHwSGdnGZU37Mzh3wPf7jlrQffbRv6ZYyrCpQqtLt7oaR21beFYb
uRTakiifeS8MD97p/XiB5/faoiVObRo+sqkTA8aCFcdlJW3QNZN1t1qfL4dSeK6f
hJgQSZgGvM9uMVzBja6UC4rMIHHWs7CChaq70itUfQ17S0ub2reVun15TsyL4RZV
eN2ndkmir8wX8Cx/5n1IBxIbktSTGZXkgQfj0DGVj51DNQv6PdZquWBKE9mjUV4Q
N0Wzr92+RK/tokh9lxYY
=Eodg
-----END PGP SIGNATURE-----

--=-mewGJBXfnMaMaQbEt/PJ--

