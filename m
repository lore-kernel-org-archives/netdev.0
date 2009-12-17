From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/2] udp: add non-linear uniform port allocation scheme
 option /proc/sys/net/ipv4/udp_port_randomization
Date: Thu, 17 Dec 2009 17:00:12 +0100
Message-ID: <4B2A558C.7080204@gmail.com>
References: <4B2933EF.9060606@ixiacom.com> <4B2A3B3B.3000308@gmail.com> <200912171716.56066.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53585 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbZLQQBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 11:01:01 -0500
In-Reply-To: <200912171716.56066.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/12/2009 16:16, Octavian Purdila a =E9crit :

> Thanks for reviewing Eric. In this thread=20
>=20
> http://kerneltrap.org/mailarchive/linux-netdev/2009/5/8/5667204 (port=
s being=20
> reused too fast)
>=20
> Stephen observed that port randomization effects on same port allocat=
ion=20
> frequency are explained by the birthday paradox.=20

But this was with TCP, not UDP. Without NAT, UDP has no timewait concep=
t.

>=20
> The RFC suggesting port randomization recognizes this issue and sugge=
st a way=20
> to overcome it, but on a first glance it looks expensive.=20
>=20
> Adding a sysctl to sequencial port allocation might not be the best o=
ption,=20
> but we thought of kicking the discussion about this issue with this p=
atch.

Before sending patches, you might first describe the issue ?

>=20
>> BTW, net-next-2.6 is not yet open, this is not the right time to sub=
mit non
>>  bug fixes patches.
>=20
> Yes, we know that, but we are still learning the details. For instanc=
e, should=20
> we refrain from sending RFC patches (as in patches we are not sure th=
at are=20
> right and want to get early feedback on) as well during the merge win=
dow?

You always *can* send RFC/patches, but we are pretty busy to correct bu=
gs,
and take some free time to rest :=3D)

Thanks
