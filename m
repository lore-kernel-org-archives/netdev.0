From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: Re: [PATCH 3/6] new pcmcia IDs for hostap
Date: Tue, 16 May 2006 17:24:52 +0200
Message-ID: <200605161724.53495.linux-arm@hrw.one.pl>
References: <200605161621.22459.linux-arm@hrw.one.pl> <4469E3F6.5070302@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, Jouni Malinen <jkmaline@cc.hut.fi>,
	Pavel Roskin <proski@gnu.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:37095 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S1751221AbWEPPY4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 11:24:56 -0400
To: netdev@vger.kernel.org
In-Reply-To: <4469E3F6.5070302@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dnia wtorek, 16 maja 2006 16:38, Jeff Garzik napisa=B3:
> Marcin Juszkiewicz wrote:
> > One more Prism2 card which works with HostAP.

> Please roll these into a single patch.  There's no need to split it u=
p
> such that there is one ID per patch.

Here's another card that would benefit from a hostap driver:

Platform: HP Ipaq hx4700 running 2.6.16-hh

root@ipaq-pxa270:~# pccardctl ident
Socket 0:
  product info: "ASUS", "802_11B_CF_CARD_25", "Version 01.00", ""
  manfid: 0x02aa, 0x0002
  function: 6 (network)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
I use D-Link DCF-660W card with WPA protected network. By default
orinoco_cs was loaded for my card so I was not able to connect. This pa=
tch
make my card working with hostap_cs (like it was when I used pcmcia-cs)=
=2E
Card was used with hostap_cs during last year in two Zaurus models (2.4=
=2E18
on one and 2.6.11 - 2.6.16 on another).

Platform: Sharp Zaurus C760 running 2.6.16 and pcmciautils 013.

root@c7x0:~# pccardctl ident
Socket 0:
  product info: "D-Link", "DCF-660W", "", ""
  manfid: 0xd601, 0x0005
  function: 6 (network)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
One more Prism2 card which works with HostAP.

Platform: Sharp Zaurus SL-5500 running 2.4.18 + hostap_cs 0.4.7

root@collie:~# cardctl ident
Socket 0:
  product info: "NETGEAR", "MA701 Wireless CF Card", ""
  manfid: 0xd601, 0x0002
  function: 6 (network)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
Platform: Sharp Zaurus SL-C3100 running 2.6.16 + pcmciautils 013

root@spitz:~# pccardctl ident
Socket 0:
  product info: "HITACHI", "microdrive", "", ""
  manfid: 0x0319, 0x0000
  function: 4 (fixed disk)
Socket 1:
  product info:"PLANEX COMMUNICATION INC","PLANEX GW-CF11X Wireless CF =
Card", "", ""
  manfid: 0xd601, 0x0010
  function: 6 ( network )

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
=46rom: Jochen Friedrich=20

Yet another card known to work OK with hostap_cs:

# pccardctl ident
Socket 0:
  no product info available
Socket 1:
  product info: "U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02=
", ""
  manfid: 0x0156, 0x0002
  function: 6 (network)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

 drivers/net/wireless/hostap/hostap_cs.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

Index: netdev-2.6/drivers/net/wireless/hostap/hostap_cs.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- netdev-2.6.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 =
16:47:27.469628352 +0200
+++ netdev-2.6/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:47=
:48.882373120 +0200
@@ -881,6 +881,21 @@
 	PCMCIA_DEVICE_PROD_ID12(
 		"ZoomAir 11Mbps High", "Rate wireless Networking",
 		0x273fe3db, 0x32a1eaee),
+	PCMCIA_DEVICE_PROD_ID1234("ASUS", "802_11B_CF_CARD_25", "Version 01.0=
0", "",
+		0x78fc06ee, 0x45a50c1e, 0xa57adb8c, 0x00000000),
+	PCMCIA_DEVICE_PROD_ID12("D-Link", "DCF-660W",
+		0x1a424a1c, 0xe78b6dcc),
+	PCMCIA_DEVICE_PROD_ID12("NETGEAR", "MA701 Wireless CF Card",
+		0x9aa79dc3, 0xd9ec98e),
+	PCMCIA_DEVICE_PROD_ID12("PLANEX COMMUNICATION INC",=20
+		"PLANEX GW-CF11X Wireless CF Card",
+		0x4703cf68, 0xfad7318d),
+	PCMCIA_DEVICE_PROD_ID123(
+		"Pretec", "CompactWLAN Card 802.11b", "2.5",
+		0x1cadd3e5, 0xe697636c, 0x7a5bfcf1),
+	PCMCIA_DEVICE_PROD_ID1234(
+		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02", ""
+		0xc7b8df9d, 0x1700d087, 0x4b74baa0, 0x00000000),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);



--=20
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

        "To be or not to be that is the question.":
         every programmer knows the answer $2b or (not $2b) is $ff.
