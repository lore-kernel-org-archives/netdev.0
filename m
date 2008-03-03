From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: network namespace ipv6 perfs
Date: Mon, 03 Mar 2008 15:42:03 +0100
Message-ID: <47CC0E3B.1040809@bull.net>
References: <47CC0920.6000005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:54108 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509AbYCCOnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 09:43:10 -0500
In-Reply-To: <47CC0920.6000005@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Hi,
>=20
> Some performance tests was made by Benjamin to watch out the impact o=
f=20
> the network namespace. The good news is there is no impact when used=20
> with or without namespaces. That has been checked using a real networ=
k=20
> device inside a network namespace.
>=20
> These results are consistent with the ones previously made for ipv4.
>=20
> http://lxc.sourceforge.net/network/bench_ipv6_graph.php
>=20
> Thanks to Benjamin who did all the performance tests :)

In these results, may be, there is one thing that should be explained.
It is the CPU utilization overhead in the 'veth' case.

Compared to physical devices or macvlan, veth interfaces don't benefit
from hardware offloading mechanisms: i.e. checksums have to be computed
by the soft. That explains the big overhead in CPU utilization when
using this kind of virtual interface.

Benjamin

>=20
> Regards
>     -- Daniel
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
> Sauf indication contraire ci-dessus:
> Compagnie IBM France
> Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, =
92400
> Courbevoie
> RCS Nanterre 552 118 465
> Forme Sociale : S.A.S.
> Capital Social : 542.737.118 ?
> SIREN/SIRET : 552 118 465 02430
>=20
>=20


--=20
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
