From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Power Efficiency Proposal] Low Power on Media Disconnect
Date: Mon, 16 Aug 2010 08:08:00 +0200
Message-ID: <1281938880.2942.68.camel@edumazet-laptop>
References: <AANLkTin3DNEPDA+vpY-WuSa8ia-sgEA8_sr9qOLpDHph@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jie.yang@atheros.com
To: LionSky <loverunning2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37471 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468Ab0HPGII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 02:08:08 -0400
Received: by wyb32 with SMTP id 32so5286442wyb.19
        for <netdev@vger.kernel.org>; Sun, 15 Aug 2010 23:08:06 -0700 (PDT)
In-Reply-To: <AANLkTin3DNEPDA+vpY-WuSa8ia-sgEA8_sr9qOLpDHph@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 ao=C3=BBt 2010 =C3=A0 13:35 +0800, LionSky a =C3=A9crit :
> It is a very typical scenario that users of laptop/Netbook experience
> Internet over wireless instead of ethernet.
> An obvious hint about that is user unplug-in the ethernet cable which
> implies that he does not want to use the ethernet. So for power
> efficiency, it is best to place ethernet adapter into a low power
> state, such as C3hot, when ethernet cable is disconnected.
> Battery life is very important for Laptop/Netbook. Currently, the
> power consumption of active idle on a typical Netbook is about 5-6
> Watt. If you placed the etherent adapter in C3hot state, about
> 0.5~1.0Watt power is saved which depneds on your H/W. This can prolon=
g
> battery life about 10%~20% which is a quite big power saving.
> Now, Linux kernel supports runtime power management. It is not a hard
> work to enable this feature on each ethernet adapter driver.
>=20
> Here I attached a simple and prototype implementation which is
> verified on a Netbook (ASUS E1005PE with Atheros AR8132 PCI-E Fast
> Ethernet Controller).
> 1. When ethernet cable is disconnected, driver places ethernet adapte=
r
> into D3hot low power state. Just as CPU go to deep C-State.
> 2. When ethernet cable is connected again, driver places ethernet bac=
k
> in D0 power state.
>=20
> To further improve the power behavior of Linux on laptop/Netbook, a
> proposal is that all ethernet drivers must support Low Power on Media

 ... should support ...

> Disconnect.
>=20
> Is it right? Welcome any comments.
>=20

I cannot say if this patch is right on the power side.
(Would it be better to handle the ethernet device power switch from a
user policy daemon, instead of forcing the policy from the driver ?)
I dont know the implications of Low Power on Media disconnect.
At least, let ethtool be able to switch on or off this automatic
behavior...

But your patch introduces a shared (static actually) variable, atl1c_d3=
=2E
Are you sure a single state is enough to handle several ethernet ports =
?



