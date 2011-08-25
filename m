From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: how to distribute irqs of ixgbevf
Date: Thu, 25 Aug 2011 10:21:21 +0200
Message-ID: <1314260481.2387.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E5602D6.90807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: "J.Hwan Kim" <frog1120@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64418 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476Ab1HYIVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:21:20 -0400
Received: by wyg24 with SMTP id 24so1458667wyg.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 01:21:19 -0700 (PDT)
In-Reply-To: <4E5602D6.90807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 ao=C3=BBt 2011 =C3=A0 17:07 +0900, J.Hwan Kim a =C3=A9crit =
:
> Hi, everyone
>=20
> The interrupts of my ixgbevf driver occurs only Core 0
> although the user space "irqbalance" serivce is working.
>=20
> How can I distribute the interrupt of RX in ixgbevf to all cores?
>=20
> cat /proc/interrupts | grep "isv"
>    97:          8          0          0          0          0        =
 =20
> 0          0          0   PCI-MSI-edge      isv0-rx-0
>    99:          7          0          0          0          0        =
 =20
> 0          0          0   PCI-MSI-edge      isv0:lsc
>   103:       2059      0          0          0          0         =20
> 0          0          0   PCI-MSI-edge      isv2-rx-0
>   104:         14        0          0          0          0         =20
> 0          0          0   PCI-MSI-edge      isv2-tx-0
>   105:          1         0          0          0          0         =
=20
> 0          0          0   PCI-MSI-edge      isv2:mbx
>=20
> "isv" is netdevice name of my ixgbevf.
>=20
>=20

Given load is very small, irqbalance chose to send interrupts on a
single cpu.
