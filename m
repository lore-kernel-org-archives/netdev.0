From: =?utf-8?b?U8OpYmFzdGllbg==?= Judenherc
	<sebastien.judenherc@agecodagis.com>
Subject: skge and sky2 stop working after a few minutes.
Date: Wed, 15 Aug 2007 21:20:37 +0000 (UTC)
Message-ID: <loom.20070815T224114-635@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:58542 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866AbXHOVZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 17:25:07 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1ILQMQ-0006QD-3f
	for netdev@vger.kernel.org; Wed, 15 Aug 2007 23:25:02 +0200
Received: from AToulouse-256-1-54-59.w86-205.abo.wanadoo.fr ([86.205.133.59])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 23:25:02 +0200
Received: from sebastien.judenherc by AToulouse-256-1-54-59.w86-205.abo.wanadoo.fr with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 23:25:02 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I can see some very strange problem with sky2 and skge interfaces with =
2.6.22,
and also 2.6.23-rc2/3.
After 8-9 minutes, the interfaces stop working. ethtool reports that th=
e link is
down and the only way to make the interfaces usable again is
removing/reinserting the module or running ethtool -r.
This occurs for both sky2 and skge for two PCs connected to a gigabit s=
witch.
The other PCs on the same switch continue to work fine (most are 100Mbi=
t/s). It
also occurs on a third PC with skge, directly connected to a 100Mbit/s =
interface
over a cross over cable. I didn't notice the problem with 2.6.19.

After 8-9 minutes, the interface stops working. ethtool reports that th=
e link is
down and the only way to make the interface usable again is removing/re=
inserting
the module or running ethtool -r.

=46or the skge interface connected to the gigabit switch, here is what =
ethtool
reports:

Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Half 1000baseT/Full=20
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Half 1000baseT/Full=20
        Advertised auto-negotiation: Yes
        Speed: Unknown! (65535)
        Duplex: Unknown! (255)
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pg
        Wake-on: g
        Current message level: 0x00000037 (55)
        Link detected: no
NIC statistics:
     tx_bytes: 0
     rx_bytes: 0
     tx_broadcast: 0
     rx_broadcast: 0
     tx_multicast: 0
     rx_multicast: 0
     tx_unicast: 0
     rx_unicast: 0
     tx_mac_pause: 0
     rx_mac_pause: 0
     collisions: 0
     multi_collisions: 0
     aborted: 0
     late_collision: 0
     fifo_underrun: 0
     fifo_overflow: 0
     rx_toolong: 0
     rx_jabber: 0
     rx_runt: 0
     rx_too_long: 0
     rx_fcs_error: 0

and here is what dmesg says just after the hangs with debug=3D16 for sk=
ge:
=2E..
eth0: tx queued, slot 127, len 1098
skge eth0: tx done slot 127
skge eth0: rx slot 394 status 0x420100 len 66
skge eth0: rx slot 395 status 0x420100 len 66
eth0: tx queued, slot 0, len 42
skge eth0: tx done slot 0
eth0: tx queued, slot 1, len 74
skge eth0: tx done slot 1
skge eth0: rx slot 396 status 0x420100 len 66
eth0: tx queued, slot 2, len 1414
skge eth0: tx done slot 2
skge eth0: rx slot 397 status 0x420100 len 66
eth0: tx queued, slot 3, len 270
skge eth0: tx done slot 3
skge eth0: rx slot 398 status 0x420100 len 66
eth0: tx queued, slot 4, len 74
skge eth0: tx done slot 4
skge eth0: rx slot 399 status 0x420100 len 66
skge eth0: phy interrupt status 0x400 0x814c
skge eth0: Link is down.

I would be happy to help.

regards
s=C3=A9bastien.

