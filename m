From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: 802.3x pause frames
Date: Tue, 11 Nov 2014 12:29:39 +0000
Message-ID: <1415708979.3398.92.camel@decadent.org.uk>
References: <545B70C9.7090702@fkie.fraunhofer.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+TPJzN4a+eTNAiiDQrU4"
Cc: netdev@vger.kernel.org
To: Julia Niewiejska <julia.niewiejska@fkie.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33237 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752943AbaKKM3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 07:29:52 -0500
In-Reply-To: <545B70C9.7090702@fkie.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+TPJzN4a+eTNAiiDQrU4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-06 at 13:59 +0100, Julia Niewiejska wrote:
> Hello,
>=20
> I indend to do some experiments with 802.3x pause frames, but I have yet=
=20
> to find a setup that works. I used a tool that generates pause frames=20
> [1] in two setups. First one consists of two virtual machines on a=20
> VMWare ESXi 5.5 server connected with each other through a virtual=20
> switch. In second setup two physical machines (Desktop PCs) were=20
> connected directly by an ethernet cable. The VMs are running Debian=20
> Wheezy 32bit while Debian Testing (Jessie) 64bit is installed on both=20
> desktop PCs. Below you will find some information on the ethernet=20
> adapters and drivers used in the VM [2], the desktop PC with the more up=
=20
> to date hardware [3] and the older machine [4]. I used the following=20
> command to activate flow control:
>=20
> ethtool -A <eth> autoneg off rx on tx on
>=20
> First of all I noticed some discrepancies between the output of=20
> mii-tools or ethtool -a and the attempt to change the flow control=20
> settings with the command above. Only the Realtek adapter actually=20
> output that it didn't support the operation, the other adapters accepted=
=20
> the settings without any error message.
>=20
> In both setups pause frames were generated on one machine while a ping=
=20
> was sent simultaneously, as suggested in [1]. While the VM connection=20
> was set to 1 Gbps the whole time, I also tested a 10 Mbps setting on the=
=20
> physical connection. Even though the pause frames were always visible in=
=20
> tcpdump at the receiver, I didn't notice any influence whatsoever in the=
=20
> ping results.
[...]

MACs that implement flow control will not pass pause frames to the host;
therefore these MACs do not implement flow control.

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-+TPJzN4a+eTNAiiDQrU4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVGIBOee/yOyVhhEJAQoNxg/9EcWZSLPhV4fq7KVhEGrSR63+eqhu2Wbi
n2G3nodejtxBt7RNgy2fXApBw9LAO69NFiVoezJx8vMkx1BWHNBf4ZrB8azZm+vu
qd+mWFBOeHiA3mdLcWSrQrO5h//2D4RB+zNAoHeZiRzE1iqlIQ7ZhaUIaRzeMvV6
XVEdIl3zocrOaSFXmTMlMcs95HJX5gZcsEKtoSISnGsXBdWsIYP4uhiivVTZUC5a
ciyJK8RjObkh2+rwsuM8KJL8C5sWoZ6OR5h2yqbRPIkwib7YArIyE+8sCWY5SFX+
2YRgm/+2dfEz44h+xmxLU1EKfHZxpAnEC7hh0sjc8jfAfTHCn/vk1TBgP32ZNkSc
aD0oCsNW0cmXxWHkzrqsuiNE/TNie3lSzfQYiE/i8zLGWfC96xRyNZUujJf48bOv
X9QJrsajCtK2tOg/V6zmjfMYhez2+Lx4Q0pWz9C5To/1aJPw0qJgJ1P88GNZ0IMY
JGb9RNpJldI7vRB1+199S316AhM2kLqxE2WRgf9N8k8TezlymVneXMG9bZJBMHDn
4a0FvHMQQbzQQOJE8TCJ6tqShMEzNHX8GY+d19RC7ty/smqp9D4ibyO3wVFBuwOV
SaIu9dUEu7WBbdySHTdlg1ooqMAEvhPgQJnlmN9fsiphWb0WLIJOLdf2NQK5iEOj
J/P9gCi35sM=
=3A8a
-----END PGP SIGNATURE-----

--=-+TPJzN4a+eTNAiiDQrU4--
