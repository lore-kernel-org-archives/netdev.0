From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.35.11 bridge drops fragmented packets
Date: Thu, 11 Aug 2011 15:39:06 +0200
Message-ID: <1313069946.3261.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1313066585.14145.18.camel@ierdnac-hp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ierdnah@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46699 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab1HKNjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 09:39:08 -0400
Received: by wyg24 with SMTP id 24so1422683wyg.19
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 06:39:06 -0700 (PDT)
In-Reply-To: <1313066585.14145.18.camel@ierdnac-hp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 ao=C3=BBt 2011 =C3=A0 15:43 +0300, Andrei Popa a =C3=A9crit=
 :
> Hello,
>=20
> We've got a problem with kernel 2.6.35.11 as it does not forward
> fragmented packets on a bridge.
> I've seen this thread
> http://lkml.indiana.edu/hypermail/linux/kernel/0604.0/0201.html and I
> thought to email you.
>=20
> The command "echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables"
> fixes the problem.
>=20
> The config from the kernel is attached.
> The network configuration is as follows:
> cisco, interace in mode trunk with allowed vlan 1501,299 -> linux ->
> cisco, interface in mode trunk with allowed vlan 1501
>=20
> The MTU on cisco and on linux interfaces is set to 1500.
> Packets with size 1500 and no fragments are forwarded succesfully,
> packets with size 1500 and fragments are not forwaded.
> On linux it's a bond comprised of eth1.1501 and eth0.1501.
> root@shaper_b2b_bucuresti:~# brctl show
> bridge name     bridge id               STP enabled     interfaces
> br1501          8000.0015170ae7b8       no              eth0.1501
>                                                         eth1.1501
> I cand see the fragmented packets arriving on eth0 and eth0.1501 but =
I
> don't see them leaving on eth1 or eth1.1501.
>=20
> Andrei
>=20

Could you give us output of 'netstat -s' to check if IP defrag drops
some packets ?



