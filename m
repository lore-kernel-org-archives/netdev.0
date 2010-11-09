From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 09 Nov 2010 07:42:13 +0100
Message-ID: <1289284933.2790.91.camel@edumazet-laptop>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <AANLkTi=HhouZymj0R7JsDy-X1LDbfT_WL0x10EMhdOho@mail.gmail.com>
	 <1289280152.2790.23.camel@edumazet-laptop>
	 <1289283797.2790.84.camel@edumazet-laptop>
	 <AANLkTikAPaU_2=wS_T3V-8xFZm-G3qutJBxY8yb0QCYL@mail.gmail.com>
	 <1289284715.2790.87.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62131 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786Ab0KIGmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 01:42:25 -0500
Received: by wwi18 with SMTP id 18so452994wwi.1
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 22:42:24 -0800 (PST)
In-Reply-To: <1289284715.2790.87.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 07:38 +0100, Eric Dumazet a =C3=A9crit=
 :

> Hmm, your clock source is HPET, that might explain the problem on a
> scheduler intensive workload.
>=20

And if a packet sniffer (dhclient for example) makes all packets being
timestamped, it also can explain a slowdown, even if there is no
scheduler artifacts.

cat /proc/net/packet

> My HP dev machine
> # grep . /sys/devices/system/clocksource/clocksource0/*
> /sys/devices/system/clocksource/clocksource0/available_clocksource:ts=
c hpet acpi_pm=20
> /sys/devices/system/clocksource/clocksource0/current_clocksource:tsc
>=20
> My laptop:
> $ grep . /sys/devices/system/clocksource/clocksource0/*
> /sys/devices/system/clocksource/clocksource0/available_clocksource:ts=
c hpet acpi_pm=20
> /sys/devices/system/clocksource/clocksource0/current_clocksource:tsc
>=20



