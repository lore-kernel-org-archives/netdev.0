From: Mihail Dakov <mihail@ng4t.com>
Subject: fou: udp encapsulation - how to configure multiple ports per tunnel
Date: Mon, 30 Jan 2017 15:52:00 +0100
Message-ID: <d7f24185-46c4-d038-7a5e-a0bd3ee4ec58@ng4t.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="C1cWGSrmcd4ugQXiFcTde1kqlWhROam9x"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud15.udmedia.de ([194.117.254.55]:50108 "EHLO
        mail.ud15.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932341AbdA3PTH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 10:19:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--C1cWGSrmcd4ugQXiFcTde1kqlWhROam9x
Content-Type: multipart/mixed; boundary="0mMEnF4FfCGHXNb0r5VrUUBJ2bEKpKPs4";
 protected-headers="v1"
From: Mihail Dakov <mihail@ng4t.com>
To: netdev@vger.kernel.org
Message-ID: <d7f24185-46c4-d038-7a5e-a0bd3ee4ec58@ng4t.com>
Subject: fou: udp encapsulation - how to configure multiple ports per tunnel

--0mMEnF4FfCGHXNb0r5VrUUBJ2bEKpKPs4
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi there,

I am having trouble setting up the following tunnels on the tx path.

#!/bin/bash

sudo ip link add name fou11 \
type ipip \
remote 192.168.1.1 \
local 192.168.2.1 \
encap fou \
encap-sport 21001 \
encap-dport 21001


sudo ip link add name fou21 \
type ipip \
remote 192.168.1.1 \
local 192.168.2.1 \
encap fou \
encap-sport 21002 \
encap-dport 21002

this script returns:

RTNETLINK answers: File exists

which tells me that the kernel doesn't use sport and/or dport to
identify a tunnel.

Is it possible to configure a tunnel with different dport and/or sport?
If so how?

P.S. On the other hand if this was possible then the kernel would need
some policy to decide which dport and/or sport to use for each packet
arriving in this tunnel.

br,md.



--0mMEnF4FfCGHXNb0r5VrUUBJ2bEKpKPs4--

--C1cWGSrmcd4ugQXiFcTde1kqlWhROam9x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE2ImKN9TTsa7xb26szkpnDjYz8AsFAliPUxQACgkQzkpnDjYz
8AsM9w//QHD5zVh/xZ2Hi/b+7F/I/QDdfxCqrwQ5R4zK+Tmdjqz07RFF40yt1dZk
B7fAvvXVuRbWo5d+lXm/5cV6DvTASreknO+PyYcN128FsQhc28lRr+V97t0WMUti
7lWK/MtfNtKOU6cbWpBvQDryJGBumvfjmwUTZi8cu3cnX2gYQazxrw06e5Jlaelk
Co14pCUMOGOojWdIZcz3vZRw/ozteaj2S2NdfFnZ7kXxE3MEIK24cfsxU2/2/rTU
QhGtfza0WFZUAgfjTD5HFao+dYXVS9mGLRJHg5GFJhfG56L0iYBP3YXDB8FkjYFW
vsxcBISSw2gdWCfsOVgDxQF2LvjeD8Y/WufkcPnA9bgY5w7R5Lfx3p6342GlfIjw
Yz586y5O9L3yBGETaARs2qEBExZWXU46wWJLu4Wtkt8T9AGqOeA1W98f2kY/ytN1
ihHJazAnn1MXdTbQWv54QqBWLEqkN6IwKZTrnzc07nvzGpkRy2c6Lokulm1FIS/q
iOg2U3ULaI8LWyWdsy9I74S5sHsB3seQg8+qTfWdqpdcs9PQmf6dI5irzhKrFbKM
4etdA1EwcLcxvHSJr5RjyYHeqDnr3pQYnozV/aYisWZVkiT10D5C5tc9k5vNbUdP
gsPe7bz6dPwXLPTLstRAjMIJ0LmkacGFJxVbyrW+GcJedhdOVcA=
=Y7OY
-----END PGP SIGNATURE-----

--C1cWGSrmcd4ugQXiFcTde1kqlWhROam9x--
