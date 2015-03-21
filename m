From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH iproute2] man ip-netns: Fix syntax in default ns
 process, indent's
Date: Sat, 21 Mar 2015 10:54:23 +0000
Message-ID: <1426935263.32382.33.camel@decadent.org.uk>
References: <1426915962-17112-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3CzuYxyo9cWzezo9eRFw"
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51142 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751250AbbCUKyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 06:54:36 -0400
In-Reply-To: <1426915962-17112-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3CzuYxyo9cWzezo9eRFw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2015-03-21 at 07:32 +0200, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
>=20
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  man/man8/ip-netns.8 | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
> index d496675..fe885db 100644
> --- a/man/man8/ip-netns.8
> +++ b/man/man8/ip-netns.8
> @@ -46,7 +46,7 @@ ip-netns \- process network namespace management
>  A network namespace is logically another copy of the network stack,
>  with its own routes, firewall rules, and network devices.
> =20
> -By default process inherits network namespace from its parent. Initially=
 all
> +By default a process inherits network namespace from its parent. Initial=
ly all
>  the processes share the same default network namespace from the init pro=
cess.
> =20
>  By convention a named network namespace is an object at
> @@ -103,10 +103,12 @@ option was specified then all the network namespace=
 names will be removed.
>  It is possible to lose the physical device when it was moved to netns an=
d
>  then this netns was deleted with a running process:
> =20
> +.RS
>      $ ip netns add net0
>      $ ip link set dev eth0 netns net0
>      $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
>      $ ip netns del net0
> +.RE

You should delete the leading spaces as well.

Ben.

>  and eth0 will appear in the default netns only after SOME_PROCESS_IN_BAC=
KGROUND
>  will exit or will be killed. To prevent this the processes running in ne=
t0

--=20
Ben Hutchings
If you seem to know what you are doing, you'll be given more to do.

--=-3CzuYxyo9cWzezo9eRFw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVQ1N5Oe/yOyVhhEJAQqf+xAArRGcfz+XhqPz0WNMxtcWGhFcGYE4vicG
1KNL0vVoDRWe6vzhG4q3+jAxwc/6rgYWbfZLcELfsxYJZ2+aXRvnP5VPhKt2RM8g
huW5Ow5LljQEWHGEZQNU4Z718nhTKF418zdp/coI+2TvnQMGRNuUhyUWXa/UMFN2
rhSl2fRl1uH3PKdlCMEn9MlCPgeIgyrXvBRdZyrgBNTtO5ZGZMkMFSMokufLaKKX
11OUi2cndP5Hm6Vxm/311BmuxEhBgh/zl3qbcYjQpAnDKCP8iFe7wToPmhzGbyjb
sPw+l4HXaMRU4Yq18+vOX7XlK5loHPAtkbxtGU68yrBRqbNzykKlC6Jixa6xjH+1
zuZ02YrIEXXvPgfYNDiO3udVg7LVUvKqXGiU2YzJdRFzE83dQWqkgYxKYlSd5YVR
JrtsofpIdhWnqmv2KcPQiQTERsziLgiHdahpBdGUrOVAkNhRylv+5CpoLdC/V3rw
NOdrYEEh2GMxT/X+B8sA/b3zESBsVvUMXgx+mM+3ornKzgnA3Xidxez/sfwyxvu6
sikLgP4JABrzNGf8K3V2wJAFfXeNkM01DfUMlZtsiL1u/1v+hrwrao/QagxQcPsK
6SSO/qVk/LticPBxzM0FR4IerX4DYDWgMgpKlICY8n9Uun5/3DTOmxDE8gXOnbGx
3qpiIxmiXkQ=
=GLU3
-----END PGP SIGNATURE-----

--=-3CzuYxyo9cWzezo9eRFw--
