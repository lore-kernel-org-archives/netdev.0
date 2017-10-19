From: Pavlos Parissis <pavlos.parissis@gmail.com>
Subject: Instability of i40e driver on 4.9 kernel
Date: Fri, 20 Oct 2017 01:02:59 +0200
Message-ID: <92118fc4-8a20-f129-193b-9c8fdf81aa24@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="WJpVl5oo2SOq6of6t5w9Qg9mnefG94DIK"
Cc: Alexander Duyck <alexander.duyck@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:53457 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdJSXDD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 19:03:03 -0400
Received: by mail-wr0-f176.google.com with SMTP id u40so3937871wrf.10
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 16:03:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WJpVl5oo2SOq6of6t5w9Qg9mnefG94DIK
Content-Type: multipart/mixed; boundary="oBvB1weDc5E2jfcUsmRXmVQqV5McCBMjM";
 protected-headers="v1"
From: Pavlos Parissis <pavlos.parissis@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>
Message-ID: <92118fc4-8a20-f129-193b-9c8fdf81aa24@gmail.com>
Subject: Instability of i40e driver on 4.9 kernel

--oBvB1weDc5E2jfcUsmRXmVQqV5McCBMjM
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

Hi all,

We have been running 4.9 kernels for several months on CentOS 7.3 and for=
 few weeks on CentOS 7.4,
and, after we replaced 10GbE cobber cards(X540-AT2 with ixgbe driver) wit=
h X710 10GbE SFP cards
using i40e driver, we noticed sever instabilities on our servers.

On several servers the links were marked down and up again, without any o=
bvious reasons expect a lot
of errors on kernel.log. We run Bird Internet daemon on our servers in or=
der to establish BGP
peerings with routers and we have observed flapping on BGP peerings. At t=
he same time we had BGP
peering stabilities issues we had kernel errors. We decided to go back to=
 3.10 kernel from CentOS,
but that process wasn't smooth as latest firmware gave us problems with s=
peed detection. We rolled
back to two version old and speed detection issue was resolved. We have b=
een running 3.10 several
weeks without any problems. Even we want certain functionality from kerne=
l 4.9, we decided to switch
back to 3.10 as stability of our systems has higher priority.

I need to mention that in all occurrences of the issue we didn't see any =
anomalies, such DDOS
attacks and etc.

I have opened https://communities.intel.com/message/501682#501682 and the=
re you can find all the
error messages and other information.

Since we noticed the issues, I have been following netdev ML and I know t=
hat there are a lot of
improvements/patched queued up for 4.14 and I am hoping those patches fix=
 our issue and most
importantly are sent to linux-stable for inclusion in 4.9 kernel.

Cheers,
Pavlos



--oBvB1weDc5E2jfcUsmRXmVQqV5McCBMjM--

--WJpVl5oo2SOq6of6t5w9Qg9mnefG94DIK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEHZDZK6DBu+YUj6+dg/yS2h9xdrkFAlnpLyMACgkQg/yS2h9x
drnQcRAAqupM6SMaj9TzGuYUZu+Eq63n+WrbOTKfNXFyzOa+WSPSHZBYu7efjI3Q
1mG1p5NJIW/2KbLIdcHpe3Y/9U7DIXDVTF2EpYVPaRn1radtoSnRyEMmbkW/ps0+
kqpiP3HVNIZ9eZInQXjT7XhXZ68+KqPHmrrk+bl3ksfYTO1YHOmsBlAYQXnleLwl
byalZiQ6PhcDRL/7YveH582TVdefnInQmDFDWUC0BZErltxbj53FLH/Zk0vLvmEh
7P5kSXdH+5wONi/O6mcCZoer0IzdEAUCQ1/ojlG6HVZEyp7FeUGTQ2uU5pWezOfv
/WcS4KsmFFuRakP+hA0UhN9slYv8PT3kNB3cLzubomhXMTg5f/8a2rOzI3cA4HRN
iJNUrW+o6VpOxgjNzMZV3/3Z1LR03yv4cL9xqVM68v1FjM9BJsmaZa1y6jOpXE6j
fhJ4puyvhYwORq2EPWUzsqW/RplF8ThLzNiAoPMjrJgZMSfDf76pTuSfvltL/Sec
D79MbhA99s6IOl0AsUlOcsTejODeRw+x24aOtj94P+pc0V7P0Cc7wWwWrroqTOIE
0B653NzJxmd1OS94x8twDdchiB5lf1fQExg4bnmEgRIHJvrRlD88pdexr9HjPppq
hsAdKgcXCiM/TCRniWQUkzAumoUNX1Breg00etFm91yeAFuAeVQ=
=HS5P
-----END PGP SIGNATURE-----

--WJpVl5oo2SOq6of6t5w9Qg9mnefG94DIK--
