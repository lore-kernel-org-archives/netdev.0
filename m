From: Marcin Juszkiewicz <openembedded-sbG99h22wavzs492ZWNkEA@public.gmane.org>
Subject: [PATCH] Add another Prism2 card to hostap
Date: Tue, 29 Jan 2008 09:42:53 +0100
Message-ID: <200801290942.56258.openembedded@haerwu.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jouni Malinen <j@w1.fi>, Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


=46rom: Marcin Juszkiewicz <openembedded-sbG99h22wavzs492ZWNkEA@public.gmane.org>

Card reported by =C5ngstr=F6m user:
http://bugs.openembedded.net/show_bug.cgi?id=3D3236

Socket 1:
   product info: "Wireless LAN", "11Mbps PC Card", "Version 01.02", ""
   manfid: 0x0156, 0x0002
   function: 6 (network)

Signed-off-by: Marcin Juszkiewicz <openembedded-sbG99h22wavzs492ZWNkEA@public.gmane.org>

diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wire=
less/hostap/hostap_cs.c
index 877d3bd..4f6707c 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -894,6 +894,9 @@ static struct pcmcia_device_id hostap_cs_ids[] =3D =
{
                "The Linksys Group, Inc.", "Wireless Network CF Card", =
"ISL37300P",
                "RevA",
                0xa5f472c2, 0x9c05598d, 0xc9049a39, 0x57a66194),
+       PCMCIA_DEVICE_PROD_ID123(
+           "Wireless LAN" , "11Mbps PC Card", "Version 01.02",
+               0x4b8870ff, 0x70e946d1, 0x4b74baa0),
        PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);

--=20
JID: hrw-jabber.org
OpenEmbedded developer/consultant

         Computers are not intelligent. They only think they are.
