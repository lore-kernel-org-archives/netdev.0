From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/6] be2net: fixes
Date: Tue, 09 Aug 2011 17:47:28 +0200
Message-ID: <1312904848.2371.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36283 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778Ab1HIPra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 11:47:30 -0400
Received: by wyg24 with SMTP id 24so83117wyg.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 08:47:29 -0700 (PDT)
In-Reply-To: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 ao=C3=BBt 2011 =C3=A0 11:27 +0530, Sathya Perla a =C3=A9=
crit :

> Pls apply.
>=20
> Sathya Perla (6):
>   be2net: remove wrong and unnecessary calls to netif_carrier_off()
>   be2net: no need to query link status
>   be2net: non-member vlan pkts not received in promiscous mode
>   be2net: use RX_FILTER cmd to program multicast addresses
>   be2net: add support for flashing Teranetics PHY firmware
>   be2net: drop pkts that do not belong to the port
>=20
>  drivers/net/benet/be.h         |    8 ++-
>  drivers/net/benet/be_cmds.c    |  140 +++++++++++++-----------------=
------
>  drivers/net/benet/be_cmds.h    |   38 ++++------
>  drivers/net/benet/be_ethtool.c |   32 ++-------
>  drivers/net/benet/be_hw.h      |   21 ++++--
>  drivers/net/benet/be_main.c    |  155 ++++++++++++++++++++++++------=
----------
>  6 files changed, 185 insertions(+), 209 deletions(-)
>=20

Not sure which recent be2net patch is problematic on 32bit arches :

Kernel: arch/x86/boot/bzImage is ready  (#280)
  Building modules, stage 2.
  MODPOST 1854 modules
ERROR: "__udivdi3" [drivers/net/benet/be2net.ko] undefined!
make[1]: *** [__modpost] Erreur 1
make: *** [modules] Erreur 2

Please fix this, thanks.



