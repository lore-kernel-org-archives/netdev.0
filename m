From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [Devel] Re: network namespace ipv6 perfs
Date: Mon, 03 Mar 2008 17:55:11 +0300
Message-ID: <47CC114F.8050104@openvz.org>
References: <47CC0920.6000005@fr.ibm.com> <47CC0E3B.1040809@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59200 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753788AbYCCO5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 09:57:18 -0500
In-Reply-To: <47CC0E3B.1040809@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery wrote:
> Daniel Lezcano wrote:
>> Hi,
>>
>> Some performance tests was made by Benjamin to watch out the impact =
of=20
>> the network namespace. The good news is there is no impact when used=
=20
>> with or without namespaces. That has been checked using a real netwo=
rk=20
>> device inside a network namespace.
>>
>> These results are consistent with the ones previously made for ipv4.
>>
>> http://lxc.sourceforge.net/network/bench_ipv6_graph.php
>>
>> Thanks to Benjamin who did all the performance tests :)
>=20
> In these results, may be, there is one thing that should be explained=
=2E
> It is the CPU utilization overhead in the 'veth' case.
>=20
> Compared to physical devices or macvlan, veth interfaces don't benefi=
t
> from hardware offloading mechanisms: i.e. checksums have to be comput=
ed
> by the soft. That explains the big overhead in CPU utilization when

You can tune the veth devices not to account checksum when unnecessary.

> using this kind of virtual interface.
>=20
> Benjamin
>=20
>> Regards
>>     -- Daniel
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>> Sauf indication contraire ci-dessus:
>> Compagnie IBM France
>> Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5,=
 92400
>> Courbevoie
>> RCS Nanterre 552 118 465
>> Forme Sociale : S.A.S.
>> Capital Social : 542.737.118 ?
>> SIREN/SIRET : 552 118 465 02430
>>
>>
>=20
>=20

