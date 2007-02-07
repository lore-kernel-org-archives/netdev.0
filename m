From: Levitsky Maxim <maximlevitsky@yahoo.com>
Subject: [PATCH] [NETDEV] [001] dmfe : trivial/spelling fixes
Date: Wed, 7 Feb 2007 10:28:49 -0800 (PST)
Message-ID: <189584.77434.qm@web38505.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tori@unhappy.mine.nu, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422656AbXBGS2v@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Maxim Levitsky <maximlevitsky@yahoo.com>
Subject: [PATCH] [NET] [001] dmfe : trivial/spelling fixes

=46ix a typo, and wrap lines on 80-th column

Signed-off-by: Maxim Levitsky <maximlevitsky@yahoo.com>

---

--- linux-2.6.20-org/drivers/net/tulip/dmfe.c=A0=A0=A02007-02-03 11:47:=
52.000000000 +0200
+++ linux-2.6.20-mod/drivers/net/tulip/dmfe.c=A0=A0=A02007-02-07 14:41:=
29.000000000 +0200
@@ -143,9 +145,13 @@
=A0#define DMFE_TX_TIMEOUT ((3*HZ)/2)=A0=A0=A0=A0=A0/* tx packet time-o=
ut time 1.5 s" */
=A0#define DMFE_TX_KICK =A0=A0(HZ/2)=A0=A0/* tx packet Kick-out time 0.=
5 s" */
=A0
-#define DMFE_DBUG(dbug_now, msg, value) if (dmfe_debug || (dbug_now)) =
printk(KERN_ERR DRV_NAME ":
%s %lx\n", (msg), (long) (value))
+#define DMFE_DBUG(dbug_now, msg, value) if (dmfe_debug || (dbug_now)) =
\
+=A0=A0=A0=A0=A0=A0=A0printk(KERN_ERR DRV_NAME ": %s %lx\n", (msg), (lo=
ng) (value))
=A0
-#define SHOW_MEDIA_TYPE(mode) printk(KERN_ERR DRV_NAME ": Change Speed=
 to %sMhz %s duplex\n",mode
& 1 ?"100":"10", mode & 4 ? "full":"half");
+#define SHOW_MEDIA_TYPE(mode) \
+=A0=A0=A0=A0=A0=A0=A0printk(KERN_ERR DRV_NAME ": \
+=A0=A0=A0=A0=A0=A0=A0Change Speed to %sMhz %s duplex\n",mode & 1 ?"100=
":"10", \
+=A0=A0=A0=A0=A0=A0=A0mode & 4 ? "full":"half");
=A0
=A0
=A0/* CR9 definition: SROM/MII */
@@ -163,10 +169,17 @@
=A0
=A0#define SROM_V41_CODE =A0 0x14
=A0
-#define SROM_CLK_WRITE(data, ioaddr)
outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);udelay(5);outl(data|CR9_SROM_R=
EAD|CR9_SRCS|CR9_SRCLK,ioaddr);udelay(5);outl(data|CR9_SROM_READ|CR9_SR=
CS,ioaddr);udelay(5);
+#define SROM_CLK_WRITE(data, ioaddr) \
+=A0=A0=A0=A0=A0=A0=A0outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);udelay(5=
);\
+=A0=A0=A0=A0=A0=A0=A0outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr=
);udelay(5);\
+=A0=A0=A0=A0=A0=A0=A0outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);udelay(5=
);
+
+#define __CHK_IO_SIZE(pci_id, dev_rev) \
+=A0=A0=A0=A0=A0=A0=A0( ((pci_id)=3D=3DPCI_DM9132_ID) || ((dev_rev) >=3D=
 0x02000030) ) ? \
+=A0=A0=A0=A0=A0=A0=A0DM9102A_IO_SIZE: DM9102_IO_SIZE
=A0
-#define __CHK_IO_SIZE(pci_id, dev_rev) ( ((pci_id)=3D=3DPCI_DM9132_ID)=
 || ((dev_rev) >=3D 0x02000030) )
? DM9102A_IO_SIZE: DM9102_IO_SIZE
-#define CHK_IO_SIZE(pci_dev, dev_rev) __CHK_IO_SIZE(((pci_dev)->device=
 << 16) |
(pci_dev)->vendor, dev_rev)
+#define CHK_IO_SIZE(pci_dev, dev_rev) \
+=A0=A0=A0=A0=A0=A0=A0__CHK_IO_SIZE(((pci_dev)->device << 16) | (pci_de=
v)->vendor, dev_rev)
=A0
=A0/* Sten Check */
=A0#define DEVICE net_device
@@ -329,7 +342,7 @@ static void dmfe_program_DM9802(struct d
=A0static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * );
=A0static void dmfe_set_phyxcer(struct dmfe_board_info *);
=A0
-/* DM910X network baord routine ---------------------------- */
+/* DM910X network board routine ---------------------------- */
=A0
=A0/*
=A0 *=A0=A0=A0=A0=A0Search DM910X board ,allocate space and register it
@@ -402,8 +415,11 @@ static int __devinit dmfe_init_one (stru
=A0=A0=A0=A0=A0=A0=A0=A0db->dev =3D dev;
=A0
=A0=A0=A0=A0=A0=A0=A0=A0/* Allocate Tx/Rx descriptor memory */
-=A0=A0=A0=A0=A0=A0=A0db->desc_pool_ptr =3D pci_alloc_consistent(pdev, =
sizeof(struct tx_desc) * DESC_ALL_CNT +
0x20,
&db->desc_pool_dma_ptr);
-=A0=A0=A0=A0=A0=A0=A0db->buf_pool_ptr =3D pci_alloc_consistent(pdev, T=
X_BUF_ALLOC * TX_DESC_CNT + 4,
&db->buf_pool_dma_ptr);
+=A0=A0=A0=A0=A0=A0=A0db->desc_pool_ptr =3D pci_alloc_consistent(pdev, =
sizeof(struct tx_desc)=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0*=
 DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0db->buf_pool_ptr =3D pci_alloc_consistent(pdev, T=
X_BUF_ALLOC=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0*=
 TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
=A0
=A0=A0=A0=A0=A0=A0=A0=A0db->first_tx_desc =3D (struct tx_desc *) db->de=
sc_pool_ptr;
=A0=A0=A0=A0=A0=A0=A0=A0db->first_tx_desc_dma =3D db->desc_pool_dma_ptr=
;
@@ -440,7 +457,8 @@ static int __devinit dmfe_init_one (stru
=A0
=A0=A0=A0=A0=A0=A0=A0=A0/* read 64 word srom data */
=A0=A0=A0=A0=A0=A0=A0=A0for (i =3D 0; i < 64; i++)
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0((u16 *) db->srom)[i] =3D=
 cpu_to_le16(read_srom_word(db->ioaddr, i));
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0((u16 *) db->srom)[i] =3D=
=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0c=
pu_to_le16(read_srom_word(db->ioaddr, i));
=A0
=A0=A0=A0=A0=A0=A0=A0=A0/* Set Node address */
=A0=A0=A0=A0=A0=A0=A0=A0for (i =3D 0; i < 6; i++)
@@ -722,7 +742,8 @@ static int dmfe_stop(struct DEVICE *dev)
=A0
=A0#if 0
=A0=A0=A0=A0=A0=A0=A0=A0/* show statistic counter */
-=A0=A0=A0=A0=A0=A0=A0printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx LO=
C:%lx TXJT:%lx RESET:%lx RCR8:%lx FAL:%lx
TT:%lx\n",
+=A0=A0=A0=A0=A0=A0=A0printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx LO=
C:%lx TXJT:%lx=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0RESET:%lx RCR8:%lx FAL:%l=
x TT:%lx\n",
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0db->tx_fifo_underrun, d=
b->tx_excessive_collision,
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0db->tx_late_collision, =
db->tx_no_carrier, db->tx_loss_carrier,
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0db->tx_jabber_timeout, =
db->reset_count, db->reset_cr8,
@@ -919,7 +940,8 @@ static void dmfe_rx_packet(struct DEVICE
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0db->rx_avail_cnt--;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0db->interval_rx_cnt++;
=A0
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pci_unmap_single(db->pdev=
, le32_to_cpu(rxptr->rdes2), RX_ALLOC_SIZE,
PCI_DMA_FROMDEVICE);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pci_unmap_single(db->pdev=
, le32_to_cpu(rxptr->rdes2),=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if ( (rdes0 & 0x300) !=3D=
 0x300) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
/* A packet without First/Last flag */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
/* reuse this SKB */
@@ -1259,7 +1334,8 @@ static void dmfe_reuse_skb(struct dmfe_b
=A0
=A0=A0=A0=A0=A0=A0=A0=A0if (!(rxptr->rdes0 & cpu_to_le32(0x80000000))) =
{
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rxptr->rx_skb_ptr =3D s=
kb;
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rxptr->rdes2 =3D cpu_to_l=
e32( pci_map_single(db->pdev, skb->data, RX_ALLOC_SIZE,
PCI_DMA_FROMDEVICE) );
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rxptr->rdes2 =3D cpu_to_l=
e32( pci_map_single(db->pdev, skb->data,=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0 =A0RX_ALLOC_SIZE, PCI=
_DMA_FROMDEVICE) );
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0wmb();
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rxptr->rdes0 =3D cpu_to=
_le32(0x80000000);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0db->rx_avail_cnt++;
@@ -1470,7 +1546,8 @@ static void allocate_rx_buffer(struct dm
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if ( ( skb =3D dev_allo=
c_skb(RX_ALLOC_SIZE) ) =3D=3D NULL )
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
break;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rxptr->rx_skb_ptr =3D s=
kb; /* FIXME (?) */
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rxptr->rdes2 =3D cpu_to_l=
e32( pci_map_single(db->pdev, skb->data, RX_ALLOC_SIZE,
PCI_DMA_FROMDEVICE) );
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rxptr->rdes2 =3D cpu_to_l=
e32( pci_map_single(db->pdev, skb->data,=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0 =A0RX_ALLOC_SIZE, PCI=
_DMA_FROMDEVICE) );
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0wmb();
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rxptr->rdes0 =3D cpu_to=
_le32(0x80000000);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0rxptr =3D rxptr->next_r=
x_desc;
@@ -1663,7 +1740,8 @@ static void dmfe_process_mode(struct dmf
=A0 *=A0=A0=A0=A0=A0Write a word to Phy register
=A0 */
=A0
-static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, u1=
6 phy_data, u32 chip_id)
+static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0 =A0 =A0u16 phy_data,=
 u32 chip_id)
=A0{
=A0=A0=A0=A0=A0=A0=A0=A0u16 i;
=A0=A0=A0=A0=A0=A0=A0=A0unsigned long ioaddr;



=20
_______________________________________________________________________=
_____________
Get your own web address. =20
Have a HUGE year through Yahoo! Small Business.
http://smallbusiness.yahoo.com/domains/?p=3DBESTDEAL
