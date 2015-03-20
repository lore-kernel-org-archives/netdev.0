From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH iproute2 v3] man ip-netns: Notice about loose device
 when do 'del'
Date: Fri, 20 Mar 2015 23:01:05 +0000
Message-ID: <1426892465.32382.13.camel@decadent.org.uk>
References: <1426434556-11119-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-14V5zu993+1DycfHznLl"
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	develop@kristov.de
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50099 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751426AbbCTXBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 19:01:12 -0400
In-Reply-To: <1426434556-11119-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-14V5zu993+1DycfHznLl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-15 at 17:49 +0200, Vadim Kochan wrote:
[...]
> --- a/man/man8/ip-netns.8
> +++ b/man/man8/ip-netns.8
> @@ -46,6 +46,9 @@ ip-netns \- process network namespace management
>  A network namespace is logically another copy of the network stack,
>  with its own routes, firewall rules, and network devices.
> =20
> +By default process inherits network namespace from its parent. Initially=
 all

Missing "a" before "process".

[...]
> +It is possible to lose the physical device when it was moved to netns an=
d
> +then this netns was deleted with a running process:
> +
> +    $ ip netns add net0
> +    $ ip link set dev eth0 netns net0
> +    $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
> +    $ ip netns del net0
[...]

Use the .RS and .RE macros to begin and end indented text, not spaces.

Ben.

--=20
Ben Hutchings
All extremists should be taken out and shot.


--=-14V5zu993+1DycfHznLl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVQymsee/yOyVhhEJAQpX9w/7Buf2rAyynKaEpyNkz4uv6aqaV4uCjQj3
a8tWdqHMQ7eUMhdZJYpBEXaXJn6PijW417Z6Hp4ihzyQHj4uHqHEJbM/CkyX3e4j
UN9rC5hZKCU4h8Qzrl29wHkWUhvJeMyI++A4D1ktJl1gQYz0FbRYBu26M0UZBQkz
7FLmp5VThnl0JWSsA136uM9z88X79A4TDWP34X3cesrc+c9zBw1csZl6np9G7uex
QT08Poa48crFmkaoUm0X03Q7vVZc03HiPYsu9UC7A5oy/TpWLra/hCc4WBUl3jfy
XxjIfofPzf/lsN08i4nDkcD8vJzSvSUa/yM0RfbKvPEyDXs/UpOWhQcmiaKqTKjL
za9o1aF6xqKAyrF9LIqJpsR1ERdADGcMT8ArZ+fQz0lSqgP1h/jq83/eIO5OjYSz
ZQ4DBQ6AK0jyol+eBgMvpDsbQbN05QnG8nn8Rvo66u+DJP5tjr8fd5NSnC18YYio
S+dwS2KrVcXYeeBea9uhK1GvjmfH88zmFgjRFMJTWtPsbpdzifYDeLtc3gPMzqN7
9Pm0q8ueJMGpDmjb46ukoyBJEeTH3fFxxYHPFiYf5Caq6/HW2cthSxuQduVi624F
XsEMhNsCddDKLEY1KW2ZqHWqUGJhLwwIjvNhWbNFlFA8NYW+R/tST9vNKbdwPNSf
7wFCAYXzZjI=
=U9wJ
-----END PGP SIGNATURE-----

--=-14V5zu993+1DycfHznLl--
