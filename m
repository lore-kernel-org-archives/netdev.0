From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: sky2 negotiating only 100Mb/s (88E8055)
Date: Sun, 3 Mar 2013 16:56:31 +0100
Message-ID: <CACna6ry1z1LS9wMDb9dYyM+9z8kEpZADXKHL0NNoAahbm8wbNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Network Development <netdev@vger.kernel.org>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:33146 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499Ab3CCP4c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Mar 2013 10:56:32 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so7870815oag.40
        for <netdev@vger.kernel.org>; Sun, 03 Mar 2013 07:56:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've problems with my:
08:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
88E8055 PCI-E Gigabit Ethernet Controller [11ab:4363] (rev 13)
using 3.4.28 kernel on my Sony notebook.

I've tried connecting it to the:
1) HP#1 (Intel card)
2) HP#2 (Broadcom card)
3) Router based on BCM4706 with BCM53125 switch
I've tried two different CAT5e cables for all the above devices. In
every case sky2 established 100Mbps link only. It couldn't achieve
1000Mb/s. Forcing it to 1000Mbps broke link. Lower speeds (100 half
duplex and 10 Mbps) are working fine.

It's not the issue with the cable or devices, because all other
configurations are working fine. I can connect:
1) HP#1 with HP#2
2) HP#1 with router
3) HP#2 with router
and I always get 1000Mbps.

So it looks like some bugged hardware or (more likely?) issue in sky2.

sky2 0000:08:00.0: eth0: disabling interface
sky2: driver version 1.30
sky2 0000:08:00.0: Yukon-2 EC Ultra chip revision 3
sky2 0000:08:00.0: irq 47 for MSI/MSI-X
sky2 0000:08:00.0: eth0: addr 00:1d:ba:19:9e:db
sky2 0000:08:00.0: eth0: enabling interface
sky2 0000:08:00.0: eth0: Link is up at 100 Mbps, full duplex, flow cont=
rol both

Can you help me with that?

--=20
Rafa=C5=82
