From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: Re: [PATCH 1/5] new pcmcia IDs for hostap - ASUS WL-110
Date: Fri, 12 May 2006 19:04:06 +0200
Message-ID: <200605121904.07784.linux-arm@hrw.one.pl>
References: <20060512165706.GA4079@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.205.148.100] ([195.205.148.100]:19425 "EHLO blue.stone.pl")
	by vger.kernel.org with ESMTP id S1750787AbWELREO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 13:04:14 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060512165706.GA4079@bougret.hpl.hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dnia pi=B1tek, 12 maja 2006 18:57, Jean Tourrilhes napisa=B3:
> Marcin Juszkiewicz wrote :

> 	I'm sorry, but I will have again to veto part of your patch.
> 	You are removing IDs from the Orinoco driver. Please don't do
> that, those card work perfectly with the orinoco driver, and some of
> us run them with the orinoco driver (orinoco is one third the
> footprint of hostap).

Ok - I will update all patches to not doing this.

Thx for answers.

----------------------------------------------------------------------
Here's another card that would benefit from a hostap driver:

Platform: HP Ipaq hx4700 running 2.6.16-hh

root@ipaq-pxa270:~# pccardctl ident
Socket 0:
  product info: "ASUS", "802_11B_CF_CARD_25", "Version 01.00", ""
  manfid: 0x02aa, 0x0002
  function: 6 (network)

root@ipaq-pxa270:~# ifconfig wlan0
wlan0     Link encap:Ethernet  HWaddr 00:0C:6E:F0:DA:CD
          inet addr:172.20.0.3  Bcast:172.20.255.255  Mask:255.255.0.0
          inet6 addr: 2001:610:600:93:20c:6eff:fef0:dacd/64 Scope:Globa=
l
          inet6 addr: fe80::20c:6eff:fef0:dacd/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:158 errors:0 dropped:0 overruns:0 frame:0
          TX packets:77 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:17978 (17.5 KiB)  TX bytes:11424 (11.1 KiB)
          Interrupt:92


Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>
Index: linux/drivers/net/wireless/hostap/hostap_cs.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:02=
:51.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:31:07.0=
00000000 +0200
@@ -935,6 +935,8 @@
 	PCMCIA_DEVICE_PROD_ID123(
 		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02",
 		0xc7b8df9d, 0x1700d087, 0x4b74baa0),
+	PCMCIA_DEVICE_PROD_ID1234("ASUS", "802_11B_CF_CARD_25", "Version 01.0=
0", "",
+				0x78fc06ee, 0x45a50c1e, 0xa57adb8c, 0x00000000),
 	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11b_PC_CARD_25",
 				0x78fc06ee, 0xdb9aa842),
 	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11B_CF_CARD_25",


--=20
JID: hrw-jabber.org
Palmtop: Sharp Zaurus C760
OpenEmbedded/OpenZaurus developer

                 We are the Knights who say: MOVE.L USP,A1
