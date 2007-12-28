From: Marcin Juszkiewicz <openembedded@haerwu.biz>
Subject: [PATCH] Add Linksys WCF11 to hostap driver
Date: Fri, 28 Dec 2007 14:16:55 +0100
Message-ID: <200712281416.59079.openembedded@haerwu.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jouni Malinen <j@w1.fi>, Pavel Roskin <proski@gnu.org>,
	netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:59786 "EHLO
	smtp.host4.kei.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbXL1NY1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 08:24:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


=46rom: Marcin Juszkiewicz <openembedded@haerwu.biz>

Linksys WCF11 submitted by =C5ngstr=F6m user.

"The Linksys Group, Inc.", "Wireless Network CF Card", "ISL37300P", "Re=
vA",
0xa5f472c2, 0x9c05598d, 0xc9049a39, 0x57a66194=20
manfid: 0x0274, 0x3301

Signed-off-by: Marcin Juszkiewicz <openembedded@haerwu.biz>

---
 drivers/net/wireless/hostap/hostap_cs.c |    4 ++++
 1 file changed, 4 insertions(+)

--- linux-2.6.23.orig/drivers/net/wireless/hostap/hostap_cs.c
+++ linux-2.6.23/drivers/net/wireless/hostap/hostap_cs.c
@@ -887,10 +887,14 @@ static struct pcmcia_device_id hostap_cs
                "Ver. 1.00",
                0x5cd01705, 0x4271660f, 0x9d08ee12),
        PCMCIA_DEVICE_PROD_ID123(
                "corega", "WL PCCL-11", "ISL37300P",
                0xa21501a, 0x59868926, 0xc9049a39),
+       PCMCIA_DEVICE_PROD_ID1234(
+               "The Linksys Group, Inc.", "Wireless Network CF Card", =
"ISL37300P",
+               "RevA",
+               0xa5f472c2, 0x9c05598d, 0xc9049a39, 0x57a66194),
        PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);


--=20
JID: hrw-jabber.org
OpenEmbedded developer/consultant

                    Resistance Is Useless! (If < 1 ohm)


