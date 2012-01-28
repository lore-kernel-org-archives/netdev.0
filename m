From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] ethtool: implement [GS]FEATURES handling
Date: Sat, 28 Jan 2012 11:02:02 +0100
Message-ID: <1327744922.7199.3.camel@edumazet-laptop>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <9327efbf43fadeadd7017926962c65c95288d50e.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <1297107597.4077.8.camel@bwh-desktop>
	 <1327413243.7231.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327419002.5400.27.camel@deadeye> <20120124190513.GC19993@rere.qmqm.pl>
	 <e16a98ed4f9d1f0dece8bdae3ebccb7222047671.1327739037.git.mirq-linux@rere.qmqm.pl>
	 <08e06fc4d7b6e4dba466422a7cc93b2e2630c978.1327739670.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:33191 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab2A1KCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 05:02:07 -0500
Received: by werb13 with SMTP id b13so2012531wer.19
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 02:02:06 -0800 (PST)
In-Reply-To: <08e06fc4d7b6e4dba466422a7cc93b2e2630c978.1327739670.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 28 janvier 2012 =C3=A0 09:37 +0100, Micha=C5=82 Miros=C5=82aw=
 a =C3=A9crit :
> v2: fix missing change CMDL_FLAG -> CMDL_BOOL for old offloads parsin=
g
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  ethtool.c |  613 ++++++++++++++++++++++++++++++++++++++++++++++++---=
---------
>  1 files changed, 490 insertions(+), 123 deletions(-)

Seems fine to me, here is the result for the new section :

I can now 'see' my tg3 doesnt support tx-tcp6-segmentation without
having to read driver source...

Extended offload state for eth3:
tx-scatter-gather: on (changeable)
tx-checksum-ipv4: on (changeable)
tx-checksum-ip-generic: off (driver-controlled)
tx-checksum-ipv6: off (driver-controlled)
highdma: on (changeable)
tx-scatter-gather-fraglist: off (driver-controlled)
tx-vlan-hw-insert: on (changeable)
rx-vlan-hw-parse: on (changeable)
rx-vlan-filter: off (driver-controlled)
vlan-challenged: off (fixed)
tx-generic-segmentation: on (changeable)
tx-lockless: off (fixed)
netns-local: off (fixed)
rx-gro: on (changeable)
rx-lro: off (driver-controlled)
tx-tcp-segmentation: on (changeable)
tx-udp-fragmentation: off (driver-controlled)
tx-gso-robust: off (driver-controlled)
tx-tcp-ecn-segmentation: off (driver-controlled)
tx-tcp6-segmentation: off (driver-controlled)
tx-fcoe-segmentation: off (driver-controlled)
tx-checksum-fcoe-crc: off (driver-controlled)
tx-checksum-sctp: off (driver-controlled)
fcoe-mtu: off (driver-controlled)
rx-ntuple-filter: off (driver-controlled)
rx-hashing: off (driver-controlled)
rx-checksum: on (changeable)
tx-nocache-copy: on (changeable)
loopback: off (changeable)

Thanks !
