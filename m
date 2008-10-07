From: Milan Kocian <milon@wq.cz>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 7 Oct 2008 14:48:21 +0200
Message-ID: <20081007124820.GG4606@ntm.vs.lam.cz>
References: <20081006202401.14f03be2@speedy> <48EACA2A.1030005@candelatech.com> <48EB488A.40409@trash.net> <200810071520.56610.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Qf1oXS95uex85X0R"
Cc: Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([212.71.155.176]:39849 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440AbYJGNbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 09:31:55 -0400
Content-Disposition: inline
In-Reply-To: <200810071520.56610.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Qf1oXS95uex85X0R
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 07, 2008 at 03:20:56PM +0300, Denys Fedoryshchenko wrote:
=20
>=20

> diff -Naur iproute2.backup/ip/iplink.c iproute2/ip/iplink.c
> --- iproute2.backup/ip/iplink.c	2008-10-05 15:41:59.000000000 +0000
> +++ iproute2/ip/iplink.c	2008-10-07 12:14:28.000000000 +0000
> @@ -54,6 +54,10 @@
>  	fprintf(stderr, "	                     mtu MTU }\n");
>  	fprintf(stderr, "	                     netns PID }\n");
>  	fprintf(stderr, "       ip link show [ DEVICE ]\n");
> +	fprintf(stderr, "       ip link add link PARENTDEV type { vlan | veth }=
 { ... | help }\n");
> +	fprintf(stderr, "       ip link add link PARENTDEV NEWDEVICE type macvl=
an { ... | help }\n");
> +	fprintf(stderr, "       ip link change link PARENTDEV type { vlan | vet=
h } { ... | help}\n");
> +	fprintf(stderr, "       ip link del dev DEVICE\n");
>  	exit(-1);
>  }
> =20
hello,

btw. How can I see vlan id on device ?
After:
# ip l a l eth0 type vlan id 100
# ip a
I see:

64: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN=20
    link/ether 00:16:d3:3e:4e:b9 brd ff:ff:ff:ff:ff:ff

No vlan id in interface name ?

# ip -V
ip utility, iproute2-ss080725

regards,

--=20
Milan Kocian

--Qf1oXS95uex85X0R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjrWpQACgkQPxnHOr4hZ+r4sgCeK1N5K9TK+mTvYy4VWzAism3c
w9oAn35EhLe6A4ja6Czib9elFO89VED6
=Ogml
-----END PGP SIGNATURE-----

--Qf1oXS95uex85X0R--
