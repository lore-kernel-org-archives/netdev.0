From: Olaf Hering <olh@suse.de>
Subject: Re: netdev-2.6 queue updated
Date: Wed, 20 Oct 2004 19:48:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020174853.GA11659@suse.de>
References: <20041016010036.GA32213@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041016010036.GA32213@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Fri, Oct 15, Jeff Garzik wrote:

>  drivers/net/typhoon.c                         |  232 +++----

> Jeff Garzik:
>   o Hand-merge typhoon conflicts
>   o [netdrvr eepro100] fix pci_iomap() args and info msg that follows
>   o [netdrvr b44] update MODULE_AUTHORS
>   o [netdrvr 8139cp] TSO support
>   o [netdev] Remove no-op in-driver implementations of ->set_config()

Current Linus tree does not compile.


diff -purN linux-2.6.9-bk4.orig/drivers/net/typhoon.c linux-2.6.9-bk4/dri=
vers/net/typhoon.c
--- linux-2.6.9-bk4.orig/drivers/net/typhoon.c	2004-10-20 13:57:29.000000=
000 +0200
+++ linux-2.6.9-bk4/drivers/net/typhoon.c	2004-10-20 14:32:17.000000000 +=
0200
@@ -2476,7 +2476,7 @@ typhoon_init_one(struct pci_dev *pdev, c
 	dev->set_mac_address	=3D typhoon_set_mac_address;
 	dev->vlan_rx_register	=3D typhoon_vlan_rx_register;
 	dev->vlan_rx_kill_vid	=3D typhoon_vlan_rx_kill_vid;
-	SET_ETHTOOL_OPS(dev, &ops);
+	SET_ETHTOOL_OPS(dev, &typhoon_ethtool_ops);
=20
 	/* We can handle scatter gather, up to 16 entries, and
 	 * we can do IP checksumming (only version 4, doh...)

--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
