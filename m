From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Wed, 22 Dec 2010 11:07:44 +0100
Message-ID: <1293012464.3027.30.camel@edumazet-laptop>
References: <4CA208C9.1020800@6wind.com>
	 <1285691629.3154.80.camel@edumazet-laptop>  <4CA21BC6.5070300@6wind.com>
	 <1285692969.3154.86.camel@edumazet-laptop>  <4CA2EF9C.9040909@6wind.com>
	 <1285749349.2615.27.camel@edumazet-laptop>
	 <1285751929.2615.30.camel@edumazet-laptop>  <4D11B7AC.8000205@6wind.com>
	 <1293011708.3027.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38235 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab0LVKHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 05:07:49 -0500
Received: by wyb28 with SMTP id 28so4852161wyb.19
        for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 02:07:48 -0800 (PST)
In-Reply-To: <1293011708.3027.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 10:55 +0100, Eric Dumazet a =C3=
=A9crit :
> Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 09:32 +0100, Nicolas Dichtel=
 a =C3=A9crit :
> > What is the status of this patch? The initial problem is still here=
 in 2.6.37-rc5+
> >=20
>=20
> I cannot reproduce the problem on net-next-2.6, are you sure we still
> need a new patch ?
>=20
> # ip tunnel add mode ipip remote 10.16.0.164 local 10.16.0.72 dev eth=
0
> # ip link show dev tunl1
> 19: tunl1: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN=20
>     link/ipip 10.16.0.72 peer 10.16.0.164
> # /root/vrrp tunl1
> # ip tunnel del tunl1
>=20
>=20

(I thought commit 332dd96f7ac15e fixed the problem for you, as it did
for me)

net/dst: dst_dev_event() called after other notifiers



