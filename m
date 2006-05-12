From: Marcin Juszkiewicz <openembedded@hrw.one.pl>
Subject: Re: [PATCH 3/5] new pcmcia IDs for hostap - D-Link DCF-660W
Date: Fri, 12 May 2006 19:06:10 +0200
Message-ID: <200605121906.11866.openembedded@hrw.one.pl>
References: <200605121545.19635.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:15285 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S1750797AbWELRGO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 13:06:14 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200605121545.19635.linux-arm@hrw.one.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Updated to not touch orinoco_cs driver.

-----------------------------------------------------------------------

I use D-Link DCF-660W card with WPA protected network. By default
orinoco_cs was loaded for my card so I was not able to connect. This pa=
tch
make my card working with hostap_cs (like it was when I used pcmcia-cs)=
=2E
Card was used with hostap_cs during last year in two Zaurus models (2.4=
=2E18
on one and 2.6.11 - 2.6.16 on another).

I do not know does removing card from orinoco_cs is correct way.

Platform: Sharp Zaurus C760 running 2.6.16 and pcmciautils 013.

root@c7x0:~# pccardctl ident
Socket 0:
  product info: "D-Link", "DCF-660W", "", ""
  manfid: 0xd601, 0x0005
  function: 6 (network)

root@c7x0:~# iwconfig wlan0
wlan0     IEEE 802.11b  ESSID:"test"
          Mode:Master  Frequency:2.422 GHz  Access Point: 00:80:C8:2C:0=
9:3F
          Bit Rate:11 Mb/s   Sensitivity=3D1/3
          Retry min limit:8   RTS thr:off   Fragment thr:off
          Encryption key:off
          Power Management:off
          Link Quality:0  Signal level:0  Noise level:0
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:0   Missed beacon:0

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:36=
:08.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:43:36.0=
00000000 +0200
@@ -974,6 +974,8 @@
 		0x273fe3db, 0x32a1eaee),
 	PCMCIA_DEVICE_PROD_ID12("Linksys", "Wireless CompactFlash Card",
 				0x0733cc81, 0x0c52f395),
+ 	PCMCIA_DEVICE_PROD_ID12("D-Link", "DCF-660W",
+				0x1a424a1c, 0xe78b6dcc),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);

--=20
JID: hrw-jabber.org
Palmtop: Sharp Zaurus C760
OpenEmbedded/OpenZaurus developer

  Woda, kt=F3rej dotykasz w rzekach, jest ostatkiem tej, kt=F3ra przesz=
=B3a
  i pocz=B1tkiem tej, kt=F3ra przyjdzie: tak samo tera=BCniejszo=B6=E6.
  		-- Leonardo da Vinci
