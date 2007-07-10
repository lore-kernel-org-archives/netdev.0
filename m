From: Marcin Juszkiewicz <openembedded@hrw.one.pl>
Subject: [PATCH] PCMCIA: add Socket Ethernet card into pcnet_cs
Date: Tue, 10 Jul 2007 11:40:28 +0200
Message-ID: <200707101140.30649.openembedded@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Marcin Juszkiewicz <openembedded@hrw.one.pl>

One card submitted by =C5ngstr=F6m user.

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Index: git/drivers/net/pcmcia/pcnet_cs.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- git.orig/drivers/net/pcmcia/pcnet_cs.c      2007-03-07 09:48:53.0465020=
55 +0100
+++ git/drivers/net/pcmcia/pcnet_cs.c   2007-03-07 09:50:26.426256388 +0100
@@ -1577,6 +1577,7 @@
        PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1103),
        PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1121),
        PCMCIA_DEVICE_PROD_ID12("2408LAN", "Ethernet", 0x352fff7f, 0x00b2e9=
41),
+       PCMCIA_DEVICE_PROD_ID1234("Socket", "CF 10/100 Ethernet Card", "Rev=
ision B", "05/11/06", 0xb38bcc2e, 0x4de88352, 0xeaca6c8d, 0x7e57c22e),
        PCMCIA_DEVICE_PROD_ID123("Cardwell", "PCMCIA", "ETHERNET", 0x953367=
2e, 0x281f1c5d, 0x3ff7175b),
        PCMCIA_DEVICE_PROD_ID123("CNet  ", "CN30BC", "ETHERNET", 0x9fe55d3d=
, 0x85601198, 0x3ff7175b),
        PCMCIA_DEVICE_PROD_ID123("Digital", "Ethernet", "Adapter", 0x9999ab=
35, 0x00b2e941, 0x4b0d829e),


-- =

JID: hrw-jabber.org
OpenEmbedded developer/consultant

                Great response time! Was that 5 baud or 10?
