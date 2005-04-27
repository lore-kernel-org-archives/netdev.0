From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.6 11/11] ixgb: Driver version, white
 space, comments, device id (fwd)
Date: Wed, 27 Apr 2005 10:53:55 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271053320.16913-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Driver version, white space, comments, device id & other

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/dri=
vers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c=A0=A0=A0=A0=A0=A0=A0 200=
5-04-05 23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c=A0=A0=A0 2005-04-05 =
23:06:38.283932752 -0700
@@ -47,7 +47,7 @@ char ixgb_driver_string[] =3D "Intel(R) PR
=A0#else
=A0#define DRIVERNAPI "-NAPI"
=A0#endif
-char ixgb_driver_version[] =3D "1.0.90-k2"DRIVERNAPI;
+char ixgb_driver_version[] =3D "1.0.95-k2"DRIVERNAPI;
=A0char ixgb_copyright[] =3D "Copyright (c) 1999-2005 Intel Corporation."=
;
=A0
=A0/* ixgb_pci_tbl - PCI Device ID Table
@@ -103,6 +103,7 @@ static int ixgb_change_mtu(struct net_de
=A0static int ixgb_set_mac(struct net_device *netdev, void *p);
=A0static irqreturn_t ixgb_intr(int irq, void *data, struct pt_regs *regs=
);
=A0static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
+
=A0#ifdef CONFIG_IXGB_NAPI
=A0static int ixgb_clean(struct net_device *netdev, int *budget);
=A0static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
@@ -1253,6 +1254,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
=A0
=A0=A0=A0=A0=A0=A0=A0 unsigned int nr_frags =3D skb_shinfo(skb)->nr_frags=
;
=A0=A0=A0=A0=A0=A0=A0 unsigned int f;
+
=A0=A0=A0=A0=A0=A0=A0 len -=3D skb->data_len;
=A0
=A0=A0=A0=A0=A0=A0=A0 i =3D tx_ring->next_to_use;
@@ -1857,7 +1833,6 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 next_skb =3D next_buffer->skb=
;
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 prefetch(next_skb);
=A0
-
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 cleaned =3D TRUE;
=A0
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 pci_unmap_single(pdev,
@@ -2108,6 +2095,7 @@ ixgb_restore_vlan(struct ixgb_adapter *a
=A0static void ixgb_netpoll(struct net_device *dev)
=A0{
=A0=A0=A0=A0=A0=A0=A0 struct ixgb_adapter *adapter =3D dev->priv;
+
=A0=A0=A0=A0=A0=A0=A0 disable_irq(adapter->pdev->irq);
=A0=A0=A0=A0=A0=A0=A0 ixgb_intr(adapter->pdev->irq, dev, NULL);
=A0=A0=A0=A0=A0=A0=A0 enable_irq(adapter->pdev->irq);
