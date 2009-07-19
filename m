From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] New device ID for sc92031 [1088:2031]
Date: Sun, 19 Jul 2009 15:03:32 -0300
Message-ID: <1248026612-12792-1-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Cesar Eduardo Barros <cesarb@cesarb.net>,
	rain_maker@root-forum.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-02.mandic.com.br ([200.225.81.133]:40747 "EHLO
	smtp-02.mandic.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755055AbZGSSKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2009 14:10:54 -0400
Received: from grumari.nitnet.com.br (HELO localhost.localdomain) (zcncxNmDysja2tXBpdiToZWJlF6Wp6IuYnI=@[200.157.204.13])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-02.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 19 Jul 2009 18:04:12 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rain_maker@root-forum.org wrote:
> Hello cesar,
>
> In a recent thread in a german linux forum, a user reported his PIC
> NIC not being recognized by the kernel.
>
> Fortunately he provided enough information and I was able to help him
> and get the device working with the sc92031 driver.
>
> The device ID is [1088:2031] (Vendor is called "Microcomputer Systems
> (M) Son"), here is the respective thread in "ubuntuusers.de"
>
> http://forum.ubuntuusers.de/topic/lankarte-unter-xubuntu-wird-nicht-e=
rkannt/
>
> (Although you might not speak german, the code provided will show
> you, that the device is actually working with your driver).
>
> It would be nice, if you include this new device ID to the
> sc92031-driver.
>
> Regards,
>
> Axel K=C3=B6llhofer (aka Rain_Maker)

Cc: rain_maker@root-forum.org
Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/sc92031.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 18821f2..e3156c9 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1593,6 +1593,7 @@ out:
 static struct pci_device_id sc92031_pci_device_id_table[] __devinitdat=
a =3D {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, 0x2031) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, 0x8139) },
+	{ PCI_DEVICE(0x1088, 0x2031) },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci, sc92031_pci_device_id_table);
--=20
1.6.3.3

