From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.19 and earlier] fib_rules: Fix dump_rules() not to
 exit early
Date: Thu, 08 Oct 2015 13:50:02 +0100
Message-ID: <1444308602.2956.256.camel@decadent.org.uk>
References: <1444066168-5566-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DBAypRr2LnXNiQZaHlmY"
Cc: Roland Dreier <roland@purestorage.com>
To: Roland Dreier <roland@kernel.org>, netdev@vger.kernel.org,
	stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1444066168-5566-1-git-send-email-roland@kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-DBAypRr2LnXNiQZaHlmY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-10-05 at 10:29 -0700, Roland Dreier wrote:
> From: Roland Dreier <roland@purestorage.com>
>=20
> Backports of 41fc014332d9 ("fib_rules: fix fib rule dumps across
> multiple skbs") introduced a regression in "ip rule show" - it ends up
> dumping the first rule over and over and never exiting, because 3.19
> and earlier are missing commit 053c095a82cf ("netlink: make
> nlmsg_end() and genlmsg_end() void"), so fib_nl_fill_rule() ends up
> returning skb->len (i.e. > 0) in the success case.
>=20
> Fix this by checking the return code for < 0 instead of !=3D 0.
>=20
> Signed-off-by: Roland Dreier <roland@purestorage.com>
> ---
> Hi, this is needed for all stable trees earlier than 4.0 that have
> picked up 41fc014332d9; so far looks like at least 3.10.y and 3.14.y
> have made such releases.
[...]

Thanks, I'm folding this into the backported patch in 3.2.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.
--=-DBAypRr2LnXNiQZaHlmY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVhZmeue/yOyVhhEJAQo7hQ/+NFkmovy6YaKLtyMIomI3WXk/6F2NBM7h
AfVdLLhaeBdCtKILV6r50wnVSptJiSvUhUbXflwhDj4qAHJRhdBijc3qL5MGbwPk
+78i3e9Yq3kVMYbSsYGjsIctnDOXiHIVSMZ7wW7+QAfW34ONQbWO9pLmlEI34l49
nIq8WbPjKfDIxkBUMyhBurORROVmr1wAf0LKdVN8PtkUSaNWZM89qDKrqaDTZzit
lDEqddtYBR8/7wlkVrMHxscGrR+qOBBix1vXBUPVZhYVmQLcARDDZ7OHrm49fqxi
1eJNNTrb1HUYGeJcEep878zEgMheFMvd/xQdxOzcwYjJkMWe97rfkVeccnMMWg61
fn0K3Hfpw/C1BU0VdApLB82DkTkpFWRAzjsEaC/qA7TY3+lzYV/Ni8BQ6NdpmBdV
IfM2dPi91FgVYxmH74idEQfDG5yHuWBnfzaVx/HSY6Mz+s0ySbB3NNvIeP20n95P
dNJQEqMGp8KE5SfylNJ+aNVjh89f2uVMH3mzaZiYWypxDaOV7PVJthzhYpanW5QE
EwZeQ0ItNrYeorotv5d7uCPi9Vc2SmxwsTz8JdyxjhDKyD3JqzsNNe5uivr6LHWv
RY3PmMys2in81jKPNSa+FBs2Ie4LXk/X/oAoOwexF2W6h+QIK3BgJGFrWopYSobN
6BDjnlr6Eq4=
=pXe7
-----END PGP SIGNATURE-----

--=-DBAypRr2LnXNiQZaHlmY--
