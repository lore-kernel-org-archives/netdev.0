From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: 3.0.0rc6: ethtool not working without a cable
Date: Wed, 6 Jul 2011 13:38:08 +0200
Message-ID: <201107061338.08573.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:36893 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab1GFLiM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 07:38:12 -0400
Received: by fxd18 with SMTP id 18so7129055fxd.11
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 04:38:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


3.0.0rc6, thinkpad t400 notebook.

If there is no cable then ethtool reports no device. It wasn't that bef=
ore=20
AFAIK.

ethtool version 2.6.36


cable disconnected:

[root@t400 ~]# ethtool eth0
Settings for eth0:
Cannot get device settings: No such device
Cannot get wake-on-lan settings: No such device
Cannot get message level: No such device
Cannot get link status: No such device
No data available
zsh: exit 75    ethtool eth0
[root@t400 ~]# ethtool -i eth0
Cannot get driver information: No such device
zsh: exit 71    ethtool -i eth0

cable connected:

[root@t400 ~]# ethtool -i eth0
driver: e1000e
version: 1.3.10-k2
firmware-version: 1.8-3
bus-info: 0000:00:19.0
[root@t400 ~]# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 2
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: off
        Supports Wake-on: pumbg
        Wake-on: d
        Current message level: 0x00000001 (1)
                               drv
        Link detected: yes


--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
