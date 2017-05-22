From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/4] Configuring traffic classes via new hardware
 offload mechanism in tc/mqprio
Date: Mon, 22 May 2017 12:31:12 -0700
Message-ID: <1495481472.4878.4.camel@intel.com>
References: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-35koCWFlgL5rtPfVkG7b"
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        sridhar.samudrala@intel.com, mitch.a.williams@intel.com,
        neerav.parikh@intel.com, netdev@vger.kernel.org
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org, Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:11417 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761419AbdEVTbY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 15:31:24 -0400
In-Reply-To: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-35koCWFlgL5rtPfVkG7b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-05-19 at 17:58 -0700, Amritha Nambiar wrote:
> The following series introduces a new harware offload mode in tc/mqprio
> where the TCs, the queue configurations and bandwidth rate limits are
> offloaded to the hardware.
> The i40e driver enables the new mqprio hardware offload mechanism
> factoring the TCs, queue configuration and bandwidth rates by creating HW
> channel VSIs.=C2=A0
>=20
> In this mode, the priority to traffic class mapping and the user
> specified queue ranges are used to configure the traffic class when the
> 'hw' option is set to 2. This is achieved by creating HW channels(VSI). A
> new channel is created for each of the traffic class configuration
> offloaded via mqprio framework except for the first TC (TC0) which is for
> the main VSI. TC0 for the main VSI is also reconfigured as per user
> provided queue parameters. Finally, bandwidth rate limits are set on
> these traffic classes through the mqprio offload framework by sending
> these rates in addition to the number of TCs and the queue
> configurations.
>=20
> Example:
> # tc qdisc add dev eth0 root mqprio num_tc 2=C2=A0=C2=A0map 0 0 0 0 1 1 1=
 1\
> =C2=A0 queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2
>=20
> To dump the bandwidth rates:
>=20
> # tc qdisc show dev eth0
> =C2=A0 qdisc mqprio 804a: root=C2=A0=C2=A0tc 2 map 0 0 0 0 1 1 1 1 0 0 0 =
0 0 0 0 0
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0queues:(0:3) (4:7)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0min rates:0bit 0bit
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0max rates:55Mbit 60Mbit
>=20

This was meant to be sent out as an RFC, but apparently that did not get
conveyed when these were sent out Friday.
--=-35koCWFlgL5rtPfVkG7b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZIzyAAAoJEOVv75VaS+3O2YwQAI5pF2bNn2uxH3Y7bNeFxWVG
DDq8PWAlhXia2Pp2SFwtRdPYlM9HhSM+Ry3//Rr8WCAM7VncTTHIDI6bTpnpn7k6
QyfUfJPOCErpEX9wk9+YtQR6q00LsoqCtDbbncXmK2HShAqXj8EQmT4tGL6EKp7v
Ad2qFl5sn4B7Te29Ev6w6zCWVWNIu+nNu+iTPMtOVmNaxJwGX67VR/fKFYeLZTAx
KHrf29BGRzI3+5OdW+h66My7SE9HrUtJqAJAVb+VE0fkhVJJ2OMa+EkImF9e0uL5
KpUeZqSGE2b0W2PEt9x8sCKKjOabv42cUxjnSpgw1A/JoEx0GWqgG8GBM1C9cjcn
lq2ca3XPJpOe467axVHfmVeKof86FQvhPJyKCPiW4LacdGZYmFiEd1iU7dFcRw+R
dLLQrOGdKhQqSk0cS7bBVat8wG7nWRgFVj+gHQ2G5r1JIuHXKzEe8RgZ/4FNkmFW
wCaR/Eiqkzx433VOLnNvzE2WqHtozZsyTmZ1hmjYGicJkMTs/b3FQCemSjbIozHv
XdmPAETtiYXOy+ImHdxyCB2t9+/YDH8SwtvdwK3HSp5+texMrz0mtdTZoSHhTdL8
MY7htu42pyTOv656EeBdhG+Ik+ZbucSYT0pXES/hpYc0K3QvATG8HH+mgqgYOpwc
udMzJXgm7Q5vLHr4Z3CP
=8WV4
-----END PGP SIGNATURE-----

--=-35koCWFlgL5rtPfVkG7b--
