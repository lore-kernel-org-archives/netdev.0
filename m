From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Testing server performance
Date: Mon, 12 Dec 2011 10:36:52 +0100
Message-ID: <1323682612.2948.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAFdo_mW0sKSZp3L75BOPBN1Sa+ZQ8WiBRC98eFLM5BaxCVrpJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:51413 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab1LLJg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 04:36:56 -0500
Received: by vcbfk14 with SMTP id fk14so3560900vcb.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 01:36:55 -0800 (PST)
In-Reply-To: <CAFdo_mW0sKSZp3L75BOPBN1Sa+ZQ8WiBRC98eFLM5BaxCVrpJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 d=C3=A9cembre 2011 =C3=A0 16:26 +0100, Igor Maravi=C4=87=
 a =C3=A9crit :
> Hi all,
> I'm currently testing how much traffic can I push through my server.
> I'm running on Ubuntu 11.10 server with net-next kernel.
> I'm using 2 Gbps NICs, Netgear GA311 and D-Link DGE-528T, that use r8=
169 driver.
> I'm generating UDP packets from a router with constant speed.
>=20
> After I push traffic to my server with max speed, it saturates.
> It receives packets at 77MBps and it sends packet with 14MBps.
> When there are no incoming traffic, but there are remaining packets i=
n
> tx fifo queue, it sends them with 40MBps.
>=20
> That all wouldn't be strange because my machine isn't any thing speci=
al
> (AMD Athlon(tm) II X2 240 on 2,8GHz, motherboard ASUS M2N68 PLUS and
> 2x2GB DDR2 RAM memory on 1066MHz),
> but the dstat shows that CPUs are maximally using 6% of their
> resources for interrupt handling.
> Beside that, nothing else is using CPU time.
> Why does it saturate on this values then? Am I doing something wrong?
> Any help is appreciated.
>=20
> BR
> Igor
>=20
> PS. Kernel is SMP enabled and I tried different bit masks for
> smp_affinity for my interfaces, but I still got the same result.

I have doubts you get such poor performance from your machine.

77Mbps, thats how many packets per second ???
