From: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Fri, 1 Oct 2010 19:02:36 +0900
Message-ID: <000401cb614f$c932c750$66f8800a@maildom.okisemi.com>
References: <4C9C7C6F.1000003@dsn.okisemi.com>
	<4CA4541F.5040804@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>,
	Tomoya MORINAGA <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang Grandegger,

Thank you for your comments.

We will modify and re-post ASAP.

I have a comment about below.
> In this driver you are using just *one* RX object. This means that the
> CPU must handle new messages as quickly as possible otherwise message
> losses will happen, right?. For sure, this will not make user's happy.
> Any chance to use more RX objects in FIFO mode?

In case implementing with FIFO mode,
received packets may be our of order.
Because our CAN register access is slow.

I am confirming our CAN HW spec and the possibility of our-of-order.

Thanks, Ohtake(OKISemi)
---- Original Message ----- 
From: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: "Masayuki Ohtak" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>; "Wolfram Sang" <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>; "Christian Pellegrin"
<chripell-VaTbYqLCNhc@public.gmane.org>; "Barry Song" <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>; "Samuel Ortiz" <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>;
<socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>; <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org>;
<andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>;
<kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; "Tomoya MORINAGA" <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>; <joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sent: Thursday, September 30, 2010 6:10 PM
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35


> Hi Ohtake,
>
> here comes my review, sorry for delay.
>
> On 09/24/2010 12:24 PM, Masayuki Ohtak wrote:
> > Hi Wolfgang and Marc,
> >
> > We have modified a pretty amount of our driver based on other accepted Socket CAN driver.
> > Additionally, We have reduced the number of lines 3601 to 1444.
>
> Much better, but I believe it could be reduced even further.
>
> > Please check below.
> >
> > Thanks, Ohtake(OKISemi)
> >
> > ---
> > CAN driver of Topcliff PCH
> >
> > Topcliff PCH is the platform controller hub that is going to be used in
> > Intel's upcoming general embedded platform. All IO peripherals in
> > Topcliff PCH are actually devices sitting on AMBA bus.
> > Topcliff PCH has CAN I/F. This driver enables CAN function.
> >
> > Signed-off-by: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> > ---
> >  drivers/net/can/Kconfig   |    8 +
> >  drivers/net/can/Makefile  |    1 +
> >  drivers/net/can/pch_can.c | 1444 +++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 1453 insertions(+), 0 deletions(-)
> >  create mode 100644 drivers/net/can/pch_can.c
> >
> > diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> > index 2c5227c..5c98a20 100644
> > --- a/drivers/net/can/Kconfig
> > +++ b/drivers/net/can/Kconfig
> > @@ -73,6 +73,14 @@ config CAN_JANZ_ICAN3
> >    This driver can also be built as a module. If so, the module will be
> >    called janz-ican3.ko.
> >
> > +config PCH_CAN
> > + tristate "PCH CAN"
> > + depends on  CAN_DEV
> > + ---help---
> > +   This driver is for PCH CAN of Topcliff which is an IOH for x86
> > +   embedded processor.
> > +   This driver can access CAN bus.
> > +
> >  source "drivers/net/can/mscan/Kconfig"
> >
> >  source "drivers/net/can/sja1000/Kconfig"
> > diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> > index 9047cd0..3ddc6a7 100644
> > --- a/drivers/net/can/Makefile
> > +++ b/drivers/net/can/Makefile
> > @@ -16,5 +16,6 @@ obj-$(CONFIG_CAN_TI_HECC) += ti_hecc.o
> >  obj-$(CONFIG_CAN_MCP251X) += mcp251x.o
> >  obj-$(CONFIG_CAN_BFIN) += bfin_can.o
> >  obj-$(CONFIG_CAN_JANZ_ICAN3) += janz-ican3.o
> > +obj-$(CONFIG_PCH_CAN) += pch_can.o
>
> Please provide patches against David Millers "net-next-2.6" GIT tree and
> use the prefix "can: " in your subject next time. See
> http://svn.berlios.de/wsvn/socketcan/trunk/README.submitting-patches
> for further information.
>
> >  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> > diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> > new file mode 100644
> > index 0000000..8c1731b
> > --- /dev/null
> > +++ b/drivers/net/can/pch_can.c
> > @@ -0,0 +1,1444 @@
> > +/*
> > + * Copyright (C) 1999 - 2010 Intel Corporation.
> > + * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License as published by
> > + * the Free Software Foundation; version 2 of the License.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + *
> > + * You should have received a copy of the GNU General Public License
> > + * along with this program; if not, write to the Free Software
> > + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
> > + */
> > +
> > +#include <linux/interrupt.h>
> > +#include <linux/delay.h>
> > +#include <linux/io.h>
> > +#include <linux/module.h>
> > +#include <linux/sched.h>
> > +#include <linux/pci.h>
> > +#include <linux/init.h>
> > +#include <linux/kernel.h>
> > +#include <linux/types.h>
> > +#include <linux/errno.h>
> > +#include <linux/netdevice.h>
> > +#include <linux/skbuff.h>
> > +#include <linux/can.h>
> > +#include <linux/can/dev.h>
> > +#include <linux/can/error.h>
> > +
> > +#define MAX_BITRATE 0x3e8
>
> Dead code? At least it's not used anywhere.
>
> > +
> > +#define MAX_MSG_OBJ 32
> > +#define MSG_OBJ_RX 0 /* The receive message object flag. */
> > +#define MSG_OBJ_TX 1 /* The transmit message object flag. */
> > +
> > +#define ENABLE 1 /* The enable flag */
> > +#define DISABLE 0 /* The disable flag */
> > +#define CAN_CTRL_INIT 0x0001 /* The INIT bit of CANCONT register. */
> > +#define CAN_CTRL_IE 0x0002 /* The IE bit of CAN control register */
> > +#define CAN_CTRL_IE_SIE_EIE 0x000e
> > +#define CAN_CTRL_CCE 0x0040
> > +#define CAN_CTRL_OPT 0x0080 /* The OPT bit of CANCONT register. */
> > +#define CAN_OPT_SILENT 0x0008 /* The Silent bit of CANOPT reg. */
> > +#define CAN_OPT_LBACK 0x0010 /* The LoopBack bit of CANOPT reg. */
> > +#define CAN_CMASK_RX_TX_SET 0x00f3
> > +#define CAN_CMASK_RX_TX_GET 0x0073
> > +#define CAN_CMASK_ALL 0xff
> > +#define CAN_CMASK_RDWR 0x80
> > +#define CAN_CMASK_ARB 0x20
> > +#define CAN_CMASK_CTRL 0x10
> > +#define CAN_CMASK_MASK 0x40
> > +
> > +#define CAN_IF_MCONT_NEWDAT 0x8000
> > +#define CAN_IF_MCONT_INTPND 0x2000
> > +#define CAN_IF_MCONT_UMASK 0x1000
> > +#define CAN_IF_MCONT_TXIE 0x0800
> > +#define CAN_IF_MCONT_RXIE 0x0400
> > +#define CAN_IF_MCONT_RMTEN 0x0200
> > +#define CAN_IF_MCONT_TXRQXT 0x0100
> > +#define CAN_IF_MCONT_EOB 0x0080
> > +#define CAN_IF_MCONT_MSGLOST 0x4000
> > +#define CAN_MASK2_MDIR_MXTD 0xc000
> > +#define CAN_ID2_DIR 0x2000
> > +#define CAN_ID_MSGVAL 0x8000
> > +
> > +#define CAN_STATUS_INT 0x8000
> > +#define CAN_IF_CREQ_BUSY 0x8000
> > +#define CAN_ID2_XTD 0x4000
> > +
> > +#define CAN_REC 0x00007f00
> > +#define CAN_TEC 0x000000ff
> > +
> > +#define PCH_RX_OK 0x00000010
> > +#define PCH_TX_OK 0x00000008
> > +#define PCH_BUS_OFF 0x00000080
> > +#define PCH_EWARN 0x00000040
> > +#define PCH_EPASSIV 0x00000020
>
> > +#define PCH_LEC0 0x00000001
> > +#define PCH_LEC1 0x00000002
> > +#define PCH_LEC2 0x00000004
> > +#define PCH_LEC_ALL (PCH_LEC0 | PCH_LEC1 | PCH_LEC2)
> > +#define PCH_STUF_ERR PCH_LEC0
> > +#define PCH_FORM_ERR PCH_LEC1
> > +#define PCH_ACK_ERR (PCH_LEC0 | PCH_LEC1)
> > +#define PCH_BIT1_ERR PCH_LEC2
> > +#define PCH_BIT0_ERR (PCH_LEC0 | PCH_LEC2)
> > +#define PCH_CRC_ERR (PCH_LEC1 | PCH_LEC2)
>
> enum {
>   PCH_LEC_STUF_ERR = 0,
> PCH_LEC_FORM_ERR,
> PCH_LEC_ACK_ERR,
> ...
> PCH_LEC_ALL
> };
>
> Seems more appropriate. More comments below.
>
> > +
> > +/* bit position of certain controller bits. */
> > +#define BIT_BITT_BRP 0
> > +#define BIT_BITT_SJW 6
> > +#define BIT_BITT_TSEG1 8
> > +#define BIT_BITT_TSEG2 12
> > +#define BIT_IF1_MCONT_RXIE 10
> > +#define BIT_IF2_MCONT_TXIE 11
> > +#define BIT_BRPE_BRPE 6
> > +#define BIT_ES_TXERRCNT 0
> > +#define BIT_ES_RXERRCNT 8
> > +#define MSK_BITT_BRP 0x3f
> > +#define MSK_BITT_SJW 0xc0
> > +#define MSK_BITT_TSEG1 0xf00
> > +#define MSK_BITT_TSEG2 0x7000
> > +#define MSK_BRPE_BRPE 0x3c0
> > +#define MSK_BRPE_GET 0x0f
> > +#define MSK_CTRL_IE_SIE_EIE 0x07
> > +#define MSK_MCONT_TXIE 0x08
> > +#define MSK_MCONT_RXIE 0x10
> > +#define PCH_CAN_NO_TX_BUFF 1
> > +#define PCI_DEVICE_ID_INTEL_PCH1_CAN 0x8818
> > +#define COUNTER_LIMIT 0xFFFF
>
> Keep alignment?
>
> > +#define PCH_CAN_CLK 50000 /* 50MHz */
>
> Please specify it in Hz already here.
>
> > +
> > +/* Total 32 OBJs */
> > +#define PCH_RX_OBJ_NUM 1
> > +#define PCH_TX_OBJ_NUM 1
> > +#define PCH_OBJ_NUM (PCH_TX_OBJ_NUM + PCH_RX_OBJ_NUM)
>
> Please explain biefly what message object are use for what purpose.
> Either here or in the initialization code.
>
> > +
> > +#define PCH_CAN_ACTIVE 0
> > +#define PCH_CAN_LISTEN 1
> > +#define PCH_CAN_STOP 0
> > +#define PCH_CAN_RUN 1
> > +
> > +#define PCH_CAN_ENABLE 0
> > +#define PCH_CAN_DISABLE 1
> > +#define PCH_CAN_ALL 2
> > +#define PCH_CAN_NONE 3
>
> The above are used in switch case and should therefore be anonymous
> enums. I suggested to remove them because I'm not a real friend of the
> helper functions which are just called *once*.
>
> > +
> > +struct pch_can_regs {
> > + u32 cont;
> > + u32 stat;
> > + u32 errc;
> > + u32 bitt;
> > + u32 intr;
> > + u32 opt;
> > + u32 brpe;
> > + u32 reserve1;
> > + u32 if1_creq;
> > + u32 if1_cmask;
> > + u32 if1_mask1;
> > + u32 if1_mask2;
> > + u32 if1_id1;
> > + u32 if1_id2;
> > + u32 if1_mcont;
> > + u32 if1_dataa1;
> > + u32 if1_dataa2;
> > + u32 if1_datab1;
> > + u32 if1_datab2;
> > + u32 reserve2;
> > + u32 reserve3[12];
> > + u32 if2_creq;
> > + u32 if2_cmask;
> > + u32 if2_mask1;
> > + u32 if2_mask2;
> > + u32 if2_id1;
> > + u32 if2_id2;
> > + u32 if2_mcont;
> > + u32 if2_dataa1;
> > + u32 if2_dataa2;
> > + u32 if2_datab1;
> > + u32 if2_datab2;
> > + u32 reserve4;
> > + u32 reserve5[20];
> > + u32 treq1;
> > + u32 treq2;
> > + u32 reserve6[2];
> > + u32 reserve7[56];
> > + u32 reserve8[3];
> > + u32 srst;
> > +};
>
> Nice.
>
> > +struct pch_can_priv {
> > + struct can_priv can;
> > + void __iomem *base;
> > + unsigned int can_num;
> > + struct pci_dev *dev;
> > + unsigned int tx_enable[MAX_MSG_OBJ];
> > + unsigned int rx_enable[MAX_MSG_OBJ];
> > + unsigned int rx_link[MAX_MSG_OBJ];
> > + unsigned int int_enables;
> > + unsigned int int_stat;
> > + unsigned int bus_off_interrupt;
> > + struct net_device *ndev;
> > + spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock*/
> > + unsigned int msg_obj[MAX_MSG_OBJ];
> > + struct pch_can_regs *regs;
>
> Please add __iomem. Do you need both, regs *and* base?
>
> > +};
> > +
> > +static struct can_bittiming_const pch_can_bittiming_const = {
> > + .name = KBUILD_MODNAME,
>
> Not sure what KBUILD_MODNAME is. Should be "pch_can", the name of the
> driver.
>
> > + .tseg1_min = 1,
> > + .tseg1_max = 16,
> > + .tseg2_min = 1,
> > + .tseg2_max = 8,
> > + .sjw_max = 4,
> > + .brp_min = 1,
> > + .brp_max = 1024, /* 6bit + extended 4bit */
> > + .brp_inc = 1,
> > +};
> > +
> > +static const struct pci_device_id pch_can_pcidev_id[] __devinitdata = {
> > + {PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_PCH1_CAN)},
> > + {}
> > +};
>
> Please use DEFINE_PCI_DEVICE_TABLE.
>
> > +static inline void pch_can_bit_set(u32 *addr, u32 mask)
> > +{
> > + iowrite32((ioread32(addr) | mask), addr);
>
> Outer brackets not needed!
>
> > +}
> > +
> > +static inline void pch_can_bit_clear(u32 *addr, u32 mask)
> > +{
> > + iowrite32((ioread32(addr) & ~(mask)), addr);
>
> Ditto.
>
> > +}
> > +
> > +static void pch_can_set_run_mode(struct pch_can_priv *priv, u32 mode)
> > +{
> > + switch (mode) {
> > + case PCH_CAN_RUN:
> > + pch_can_bit_clear(&(priv->regs)->cont, CAN_CTRL_INIT);
> > + break;
> > +
> > + case PCH_CAN_STOP:
> > + pch_can_bit_set(&(priv->regs)->cont, CAN_CTRL_INIT);
> > + break;
> > +
> > + default:
> > + dev_err(&priv->ndev->dev, "%s -> Invalid Mode.\n", __func__);
> > + break;
> > + }
> > +}
> > +
> > +static void pch_can_get_run_mode(struct pch_can_priv *priv, u32 *mode)
> > +{
> > + u32 reg_val = ioread32(&(priv->regs)->cont);
>
> I don't think you need the brackets around "priv->regs". Therefore I
> suggest s/&(priv->regs)/&priv->regs/ for the whole file.
>
> > +
> > + if (reg_val & CAN_CTRL_INIT)
> > + *mode = PCH_CAN_STOP;
> > + else
> > + *mode = PCH_CAN_RUN;
> > +}
>
> These are the helper functions I complained about above. And reg_val is
> not really needed.
>
> > +static void pch_can_set_optmode(struct pch_can_priv *priv)
> > +{
> > + u32 reg_val = ioread32(&(priv->regs)->opt);
> > +
> > + if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
> > + reg_val |= CAN_OPT_SILENT;
> > +
> > + if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
> > + reg_val |= CAN_OPT_LBACK;
> > +
> > + pch_can_bit_set(&(priv->regs)->cont, CAN_CTRL_OPT);
> > + iowrite32(reg_val, &(priv->regs)->opt);
> > +}
> > +
> > +static void pch_can_set_int_custom(struct pch_can_priv *priv)
> > +{
> > + /* Clearing the IE, SIE and EIE bits of Can control register. */
> > + pch_can_bit_clear(&(priv->regs)->cont, CAN_CTRL_IE_SIE_EIE);
> > +
> > + /* Appropriately setting them. */
> > + pch_can_bit_set(&(priv->regs)->cont,
> > + ((priv->int_enables & MSK_CTRL_IE_SIE_EIE) << 1));
> > +}
> > +
> > +/* This function retrieves interrupt enabled for the CAN device. */
> > +static void pch_can_get_int_enables(struct pch_can_priv *priv, u32 *enables)
> > +{
> > + u32 reg_ctrl_val = ioread32(&(priv->regs)->cont);
> > +
> > + /* Obtaining the status of IE, SIE and EIE interrupt bits. */
> > + *enables = ((reg_ctrl_val & CAN_CTRL_IE_SIE_EIE) >> 1);
>
> Do you really need an extra variable?
>
> > +}
> > +
> > +static void pch_can_set_int_enables(struct pch_can_priv *priv, u32 interrupt_no)
> > +{
> > + switch (interrupt_no) {
> > + case PCH_CAN_ENABLE:
> > + pch_can_bit_set(&(priv->regs)->cont, CAN_CTRL_IE);
> > + break;
> > +
> > + case PCH_CAN_DISABLE:
> > + pch_can_bit_clear(&(priv->regs)->cont, CAN_CTRL_IE);
> > + break;
> > +
> > + case PCH_CAN_ALL:
> > + pch_can_bit_set(&(priv->regs)->cont, CAN_CTRL_IE_SIE_EIE);
> > + break;
> > +
> > + case PCH_CAN_NONE:
> > + pch_can_bit_clear(&(priv->regs)->cont, CAN_CTRL_IE_SIE_EIE);
> > + break;
> > +
> > + default:
> > + dev_err(&priv->ndev->dev, "Invalid interrupt number.\n");
> > + break;
> > + }
> > +}
> > +
> > +static void pch_can_check_if1_busy(struct pch_can_priv *priv, u32 num)
> > +{
> > + u32 counter = COUNTER_LIMIT;
> > + u32 if1_creq;
> > +
> > + iowrite32(num, &(priv->regs)->if1_creq);
> > + while (counter) {
> > + if1_creq = (ioread32(&(priv->regs)->if1_creq)) &
> > +      CAN_IF_CREQ_BUSY;
> > + if (!if1_creq)
> > + break;
> > + counter--;
> > + }
> > + if (!counter)
> > + dev_err(&priv->ndev->dev, "IF1 BUSY Flag is set forever.\n");
>
> Please use a defined delay for the above timeout. How long does it
> usually take the bit to toggle? A small delay, e.g. udelay(1) could be
> fine. This function is called in the time critical path!
>
> > +}
> > +
> > +static void pch_can_check_if2_busy(struct pch_can_priv *priv, u32 num)
> > +{
> > + u32 counter = COUNTER_LIMIT;
> > + u32 if2_creq;
> > +
> > + iowrite32(num, &(priv->regs)->if2_creq);
> > + while (counter) {
> > + if2_creq = (ioread32(&(priv->regs)->if2_creq)) &
> > +      CAN_IF_CREQ_BUSY;
> > + if (!if2_creq)
> > + break;
> > + counter--;
> > + }
> > + if (!counter)
> > + dev_err(&priv->ndev->dev, "IF2 BUSY Flag is set forever.\n");
> > +}
>
> Duplicated code!
>
> > +static void pch_can_set_rx_enable(struct pch_can_priv *priv, u32 buff_num,
> > +   u32 set)
> > +{
> > + unsigned long flags;
> > +
> > + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> > + /*Reading the receive buffer data from RAM to Interface1 registers */
>
> Space after /* ?
>
> > + iowrite32(CAN_CMASK_RX_TX_GET, &(priv->regs)->if1_cmask);
> > + pch_can_check_if1_busy(priv, buff_num); /* Read from MsgRAN */
> > +
> > + /* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
> > + iowrite32((CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL),
> > +   (&(priv->regs)->if1_cmask));
> > +
> > + if (set == ENABLE) {
> > + /* Setting the MsgVal and RxIE bits */
> > + pch_can_bit_set(&(priv->regs)->if1_mcont, CAN_IF_MCONT_RXIE);
> > + pch_can_bit_set(&(priv->regs)->if1_id2, CAN_ID_MSGVAL);
> > +
> > + } else if (set == DISABLE) {
> > + /* Resetting the MsgVal and RxIE bits */
> > + pch_can_bit_clear(&(priv->regs)->if1_mcont, CAN_IF_MCONT_RXIE);
> > + pch_can_bit_clear(&(priv->regs)->if1_id2, CAN_ID_MSGVAL);
> > + }
> > +
> > + pch_can_check_if1_busy(priv, buff_num); /* Write to MsgRAM */
> > + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> > +}
> > +
> > +static void pch_can_rx_enable_all(struct pch_can_priv *priv)
> > +{
> > + u32 i;
> > +
> > + /* Traversing to obtain the object configured as receivers. */
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_RX)
> > + pch_can_set_rx_enable(priv, i + 1, ENABLE);
> > + }
> > +}
> > +
> > +static void pch_can_rx_disable_all(struct pch_can_priv *priv)
> > +{
> > + u32 i;
> > +
> > + /* Traversing to obtain the object configured as receivers. */
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_RX)
> > + pch_can_set_rx_enable(priv, (i + 1), DISABLE);
> > + }
> > +}
> > +
> > +static void pch_can_set_tx_enable(struct pch_can_priv *priv, u32 buff_num,
> > + u32 set)
> > +{
> > + unsigned long flags;
> > +
> > + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> > + /* Reading the Msg buffer from Message RAM to Interface2 registers. */
> > + iowrite32(CAN_CMASK_RX_TX_GET, (&(priv->regs)->if1_cmask));
> > + pch_can_check_if1_busy(priv, buff_num);
> > +
> > + /* Setting the IF2CMASK register for accessing the
> > + MsgVal and TxIE bits */
> > + iowrite32((CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL),
> > + (&(priv->regs)->if1_cmask));
> > +
> > + if (set == ENABLE) {
> > + /* Setting the MsgVal and TxIE bits */
> > + pch_can_bit_set(&(priv->regs)->if1_mcont, CAN_IF_MCONT_TXIE);
> > + pch_can_bit_set(&(priv->regs)->if1_id2, CAN_ID_MSGVAL);
> > + } else if (set == DISABLE) {
> > + /* Resetting the MsgVal and TxIE bits. */
> > + pch_can_bit_clear(&(priv->regs)->if1_mcont, CAN_IF_MCONT_TXIE);
> > + pch_can_bit_clear(&(priv->regs)->if1_id2, CAN_ID_MSGVAL);
> > + }
> > +
> > + pch_can_check_if1_busy(priv, buff_num); /* Write to MsgRAM */
> > + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> > +}
> > +
> > +static void pch_can_tx_enable_all(struct pch_can_priv *priv)
> > +{
> > + u32 i;
> > +
> > + /* Traversing to obtain the object configured as transmit object. */
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_TX)
> > + pch_can_set_tx_enable(priv, (i + 1), ENABLE);
> > + }
> > +}
> > +
> > +static void pch_can_tx_disable_all(struct pch_can_priv *priv)
> > +{
> > + u32 i;
> > +
> > + /* Traversing to obtain the object configured as transmit object. */
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_TX)
> > + pch_can_set_tx_enable(priv, (i + 1), DISABLE);
> > + }
> > +}
> > +
> > +static void pch_can_get_rx_enable(struct pch_can_priv *priv, u32 buff_num,
> > + u32 *enable)
> > +{
> > + unsigned long flags;
> > +
> > + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> > + iowrite32(CAN_CMASK_RX_TX_GET, (&(priv->regs)->if1_cmask));
> > + pch_can_check_if1_busy(priv, buff_num);
> > +
> > + if (((ioread32(&(priv->regs)->if1_id2)) & CAN_ID_MSGVAL) &&
> > + ((ioread32(&(priv->regs)->if1_mcont)) &
> > + CAN_IF_MCONT_RXIE))
> > + *enable = ENABLE;
> > + else
> > + *enable = DISABLE;
> > + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> > +}
> > +
> > +static void pch_can_get_tx_enable(struct pch_can_priv *priv, u32 buff_num,
> > + u32 *enable)
> > +{
> > + unsigned long flags;
> > +
> > + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> > + iowrite32(CAN_CMASK_RX_TX_GET, &(priv->regs)->if1_cmask);
> > + pch_can_check_if1_busy(priv, buff_num);
> > +
> > + if (((ioread32(&(priv->regs)->if1_id2)) & CAN_ID_MSGVAL) &&
> > + ((ioread32(&(priv->regs)->if1_mcont)) &
> > + CAN_IF_MCONT_TXIE)) {
> > + *enable = ENABLE;
> > + } else {
> > + *enable = DISABLE;
> > + }
> > + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> > +}
> > +
> > +static int pch_can_int_pending(struct pch_can_priv *priv)
> > +{
> > + return ioread32(&(priv->regs)->intr) & 0xffff;
> > +}
> > +
> > +static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
> > +        u32 buffer_num, u32 set)
> > +{
> > + unsigned long flags;
> > +
> > + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> > + iowrite32(CAN_CMASK_RX_TX_GET, &(priv->regs)->if1_cmask);
> > + pch_can_check_if1_busy(priv, buffer_num);
> > + iowrite32((CAN_CMASK_RDWR | CAN_CMASK_CTRL), &(priv->regs)->if1_cmask);
> > + if (set == ENABLE)
> > + pch_can_bit_clear(&(priv->regs)->if1_mcont, CAN_IF_MCONT_EOB);
> > + else
> > + pch_can_bit_set(&(priv->regs)->if1_mcont, CAN_IF_MCONT_EOB);
> > +
> > + pch_can_check_if1_busy(priv, buffer_num);
> > + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> > +}
> > +
> > +static void pch_can_get_rx_buffer_link(struct pch_can_priv *priv,
> > +        u32 buffer_num, u32 *link)
> > +{
> > + u32 reg_val;
>
> Really needed?
>
> > + unsigned long flags;
> > +
> > + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> > + iowrite32(CAN_CMASK_RX_TX_GET, &(priv->regs)->if1_cmask);
> > + pch_can_check_if1_busy(priv, buffer_num);
> > +
> > + reg_val = ioread32(&(priv->regs)->if1_mcont);
> > + if (reg_val & CAN_IF_MCONT_EOB)
> > + *link = DISABLE;
> > + else
> > + *link = ENABLE;
> > + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> > +}
> > +
> > +static void pch_can_clear_buffers(struct pch_can_priv *priv)
> > +{
> > + u32 i;
> > + u32 rx_buff_num;
> > + u32 tx_buff_num;
>
> Really needed?
>
> > +
> > + iowrite32(CAN_CMASK_RX_TX_SET, &(priv->regs)->if1_cmask);
> > + iowrite32(CAN_CMASK_RX_TX_SET, &(priv->regs)->if2_cmask);
> > + iowrite32(0xffff, &(priv->regs)->if1_mask1);
> > + iowrite32(0xffff, &(priv->regs)->if1_mask2);
> > + iowrite32(0xffff, &(priv->regs)->if2_mask1);
> > + iowrite32(0xffff, &(priv->regs)->if2_mask2);
> > +
> > + iowrite32(0x0, &(priv->regs)->if1_id1);
> > + iowrite32(0x0, &(priv->regs)->if1_id2);
> > + iowrite32(0x0, &(priv->regs)->if2_id1);
> > + iowrite32(0x0, &(priv->regs)->if2_id2);
> > + iowrite32(0x0, &(priv->regs)->if1_mcont);
> > + iowrite32(0x0, &(priv->regs)->if2_mcont);
> > + iowrite32(0x0, &(priv->regs)->if1_dataa1);
> > + iowrite32(0x0, &(priv->regs)->if1_dataa2);
> > + iowrite32(0x0, &(priv->regs)->if1_datab1);
> > + iowrite32(0x0, &(priv->regs)->if1_datab2);
> > + iowrite32(0x0, &(priv->regs)->if2_dataa1);
> > + iowrite32(0x0, &(priv->regs)->if2_dataa2);
> > + iowrite32(0x0, &(priv->regs)->if2_datab1);
> > + iowrite32(0x0, &(priv->regs)->if2_datab2);
> > +
> > + for (i = 1; i <= (MAX_MSG_OBJ / 2); i++) {
> > + rx_buff_num = 2 * i;
> > + tx_buff_num = (2 * i) - 1;
> > +
> > + iowrite32(rx_buff_num, &(priv->regs)->if1_creq);
> > + iowrite32(tx_buff_num, &(priv->regs)->if2_creq);
> > +
> > + mdelay(10);
> > + }
> > +}
> > +
> > +static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
> > +{
> > + u32 i;
> > + unsigned long flags;
> > +
> > + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> > + /* For accssing MsgVal, ID and EOB bit */
> > + iowrite32((CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL),
> > + (&(priv->regs)->if1_cmask));
> > + iowrite32((CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL),
> > + (&(priv->regs)->if2_cmask));
> > + iowrite32(0x0, (&(priv->regs)->if1_id1));
> > + iowrite32(0x0, (&(priv->regs)->if1_id2));
> > +
> > + /* Resetting DIR bit for reception */
> > + iowrite32(0x0, (&(priv->regs)->if2_id1));
> > +
> > + /* Setting DIR bit for transmission */
> > + iowrite32((CAN_ID2_DIR | (0x7ff << 2)),
> > + (&(priv->regs)->if2_id2));
> > +
> > + /* Setting EOB bit for receiver */
> > + iowrite32(CAN_IF_MCONT_EOB, &(priv->regs)->if1_mcont);
> > +
> > + /* Setting EOB bit for transmitter */
> > + iowrite32(CAN_IF_MCONT_EOB, (&(priv->regs)->if2_mcont));
> > +
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_RX)
> > + pch_can_check_if1_busy(priv, i + 1);
> > + else if (priv->msg_obj[i] == MSG_OBJ_TX)
> > + pch_can_check_if2_busy(priv, i + 1);
> > + else
> > + dev_err(&priv->ndev->dev, "Invalid OBJ\n");
> > + }
> > +
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_RX) {
> > + iowrite32(CAN_CMASK_RX_TX_GET,
> > + &(priv->regs)->if1_cmask);
> > + pch_can_check_if1_busy(priv, i+1);
> > +
> > + pch_can_bit_clear(&(priv->regs)->if1_id2, 0x1fff);
> > + pch_can_bit_clear(&(priv->regs)->if1_id2, CAN_ID2_XTD);
>
> Could'nt it be set just by one call?
>
> > + iowrite32(0, (&(priv->regs)->if1_id1));
> > + pch_can_bit_set(&(priv->regs)->if1_id2, 0);
> > + pch_can_bit_set(&(priv->regs)->if1_mcont,
> > + CAN_IF_MCONT_UMASK);
> > + pch_can_bit_set(&(priv->regs)->if2_mcont,
> > + CAN_IF_MCONT_UMASK);
> > +
> > + iowrite32(0, &(priv->regs)->if1_mask1);
> > + pch_can_bit_clear(&(priv->regs)->if1_mask2, 0x1fff);
> > + pch_can_bit_clear(&(priv->regs)->if1_mask2,
> > +   CAN_MASK2_MDIR_MXTD);
> > +
> > + iowrite32(0, &(priv->regs)->if2_mask1);
> > + pch_can_bit_clear(&(priv->regs)->if2_mask2, 0x1fff);
> > +
> > + /* Setting CMASK for writing */
> > + iowrite32((CAN_CMASK_RDWR | CAN_CMASK_MASK |
> > +    CAN_CMASK_ARB | CAN_CMASK_CTRL),
> > +   (&(priv->regs)->if1_cmask));
> > +
> > + pch_can_check_if1_busy(priv, i+1);
> > + }
> > + }
> > + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> > +}
> > +
> > +static void pch_can_open(struct pch_can_priv *priv)
>
> Probably pch_can_init is the better name.
>
> > +{
> > + /* Stopping the Can device. */
> > + pch_can_set_run_mode(priv, PCH_CAN_STOP);
> > +
> > + /* Clearing all the message object buffers. */
> > + pch_can_clear_buffers(priv);
> > +
> > + /* Configuring the respective message object as either rx/tx object. */
> > + pch_can_config_rx_tx_buffers(priv);
> > +
> > + /* Enabling all receive objects. */
> > + pch_can_rx_enable_all(priv);
> > +
> > + /* Enabling all transmit objects. */
> > + pch_can_tx_enable_all(priv);
> > +
> > + /* Enabling the interrupts. */
> > + pch_can_set_int_enables(priv, PCH_CAN_ALL);
> > +
> > + /* Setting the CAN to run mode. */
> > + pch_can_set_run_mode(priv, PCH_CAN_RUN);
>
> Hm, you start the controller here... more later.
>
> > +}
> > +
> > +static void pch_can_release(struct pch_can_priv *priv)
> > +{
> > + /* Stooping the CAN device. */
> > + pch_can_set_run_mode(priv, PCH_CAN_STOP);
> > +
> > + /* Disabling the interrupts. */
> > + pch_can_set_int_enables(priv, PCH_CAN_NONE);
> > +
> > + /* Disabling all the receive object. */
> > + pch_can_rx_disable_all(priv);
> > +
> > + /* Disabling all the transmit object. */
> > + pch_can_tx_disable_all(priv);
> > +}
> > +
> > +/* This function clears interrupt(s) from the CAN device. */
> > +static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
> > +{
> > + if (mask == CAN_STATUS_INT) {
> > + ioread32(&(priv->regs)->stat);
> > + return;
> > + }
> > +
> > + /* Clear interrupt for transmit object */
> > + if (priv->msg_obj[mask - 1] == MSG_OBJ_TX) {
> > + /* Setting CMASK for clearing interrupts for
> > + frame transmission. */
> > + iowrite32((CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB),
> > + (&(priv->regs)->if2_cmask));
> > +
> > + /* Resetting the ID registers. */
> > + pch_can_bit_set(&(priv->regs)->if2_id2,
> > +        (CAN_ID2_DIR | (0x7ff << 2)));
> > + iowrite32(0x0, (&(priv->regs)->if2_id1));
> > +
> > + /* Claring NewDat, TxRqst & IntPnd */
> > + pch_can_bit_clear(&(priv->regs)->if2_mcont,
> > +   (CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
> > +    CAN_IF_MCONT_TXRQXT));
> > + pch_can_check_if2_busy(priv, mask);
> > + }
> > + /* Clear interrupt for receive object */
> > + else if (priv->msg_obj[mask - 1] == MSG_OBJ_RX) {
>
> Should be "} else if ..."
>
> > + /* Setting CMASK for clearing the reception interrupts. */
> > + iowrite32((CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB),
> > +   (&(priv->regs)->if2_cmask));
> > +
> > + /* Clearing the Dir bit. */
> > + pch_can_bit_clear(&(priv->regs)->if2_id2, CAN_ID2_DIR);
> > +
> > + /* Clearing NewDat & IntPnd */
> > + pch_can_bit_clear(&(priv->regs)->if2_mcont,
> > +   (CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND));
> > +
> > + pch_can_check_if2_busy(priv, mask);
> > + }
> > +}
> > +
> > +static int pch_can_get_buffer_status(struct pch_can_priv *priv)
> > +{
> > + u32 reg_treq1;
> > + u32 reg_treq2;
>
> Really needed?
>
> > +
> > + /* Reading the transmission request registers. */
> > + reg_treq1 = (ioread32(&(priv->regs)->treq1) & 0xffff);
> > + reg_treq2 = ((ioread32(&(priv->regs)->treq2) & 0xffff) << 16);
> > +
> > + return reg_treq1 | reg_treq2;
> > +}
> > +
> > +static void pch_can_reset(struct pch_can_priv *priv)
> > +{
> > + /* write to sw reset register */
> > + iowrite32(1, (&(priv->regs)->srst));
> > + iowrite32(0, (&(priv->regs)->srst));
> > +}
> > +
> > +static void pch_can_msg_obj(struct net_device *ndev, u32 status)
> > +{
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > + u32 reg;
> > + struct sk_buff *skb;
> > + struct can_frame *cf;
> > + canid_t id;
> > + u32 ide;
> > + u32 rtr;
> > + int i, j;
> > + struct net_device_stats *stats = &(priv->ndev->stats);
> > +
> > + /* Reading the messsage object from the Message RAM */
> > + iowrite32(CAN_CMASK_RX_TX_GET, &(priv->regs)->if2_cmask);
> > + pch_can_check_if2_busy(priv, status);
> > +
> > + /* Reading the MCONT register. */
> > + reg = ioread32(&(priv->regs)->if2_mcont);
> > + reg &= 0xffff;
> > +
> > + /* If MsgLost bit set. */
> > + if (reg & CAN_IF_MCONT_MSGLOST) {
> > + pch_can_bit_clear(&(priv->regs)->if2_mcont,
> > +   CAN_IF_MCONT_MSGLOST);
> > + dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
>
> That should create an error message as well.
>
> > + }
> > + /* Read the direction bit for determination of remote frame . */
> > + rtr = (ioread32((&(priv->regs)->if2_id2)) &  CAN_ID2_DIR);
> > + /* Clearing interrupts. */
> > + pch_can_int_clr(priv, status);
> > + /* Hanlde reception interrupt */
>
> Typo!
>
> > + if (priv->msg_obj[status - 1] == MSG_OBJ_RX) {
> > + if (!(reg & CAN_IF_MCONT_NEWDAT)) {
> > + dev_err(&priv->ndev->dev, "MCONT_NEWDAT isn't SET.\n");
> > + return;
> > + }
> > + skb = alloc_can_skb(priv->ndev, &cf);
> > + if (!skb)
> > + return;
> > +
> > + ide = ((ioread32(&(priv->regs)->if2_id2)) & CAN_ID2_XTD) >> 14;
> > + if (ide) {
> > + id = (ioread32(&(priv->regs)->if2_id1) & 0xffff);
> > + id |= (((ioread32(&(priv->regs)->if2_id2)) &
> > +     0x1fff) << 16);
> > + cf->can_id = (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
> > + } else {
> > + id = (((ioread32(&(priv->regs)->if2_id2)) &
> > +   (CAN_SFF_MASK << 2)) >> 2);
> > + cf->can_id = (id & CAN_SFF_MASK);
> > + }
> > +
> > + if (rtr) {
> > + cf->can_dlc = 0;
> > + cf->can_id |= CAN_RTR_FLAG;
> > + } else {
> > + cf->can_dlc = ((ioread32(&(priv->regs)->if2_mcont)) &
> > +    0x0f);
> > + }
> > +
> > + /* Reading back the data. */
> > + for (i = 0, j = 0; i < cf->can_dlc; j++) {
> > + reg = ioread32(&(priv->regs)->if2_dataa1 + j*4);
> > + cf->data[i++] = cpu_to_le32(reg & 0xff);
> > + if (i == cf->can_dlc)
> > + break;
> > + cf->data[i++] = cpu_to_le32((reg & (0xff << 8)) >> 8);
> > + }
> > + netif_rx(skb);
> > + stats->rx_packets++;
> > + stats->rx_bytes += cf->can_dlc;
> > + } else if (priv->msg_obj[status - 1] == MSG_OBJ_TX) {
> > + /* Hanlde transmission interrupt */
>
> Typo!
>
> > + can_get_echo_skb(priv->ndev, 0);
> > + netif_wake_queue(priv->ndev);
> > + }
> > +}
> > +
> > +static void pch_can_error(struct net_device *ndev, u32 status)
> > +{
> > + struct sk_buff *skb;
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > + struct can_frame *cf;
> > + u32 errc;
> > + struct net_device_stats *stats = &(priv->ndev->stats);
> > +
> > + skb = alloc_can_err_skb(ndev, &cf);
> > + if (!skb) {
> > + dev_err(&ndev->dev, "%s -> No memory.\n", __func__);
>
> Please drop the error message.
>
> > + return;
> > + }
> > +
> > + if (status & PCH_BUS_OFF) {
> > + if (!priv->bus_off_interrupt) {
> > + pch_can_tx_disable_all(priv);
> > + pch_can_rx_disable_all(priv);
> > +
> > + priv->can.state = CAN_STATE_BUS_OFF;
> > + cf->can_id |= CAN_ERR_BUSOFF;
> > + can_bus_off(ndev);
> > +
> > + priv->bus_off_interrupt = 1;
> > + pch_can_set_run_mode(priv, PCH_CAN_RUN);
>
> Hm, you automatically restart the contoller after a bus-off. That's not
> the intended behaviour. It's up to the user to define how and when the
> device should recover from bus-off. For further information read
>
> http://lxr.linux.no/#linux+v2.6.35.7/Documentation/networking/can.txt#L767
>
> > + }
> > + }
>
> > + /* Warning interrupt. */
> > + if (status & PCH_EWARN) {
> > + priv->can.state = CAN_STATE_ERROR_WARNING;
> > + priv->can.can_stats.error_warning++;
> > + cf->can_id |= CAN_ERR_CRTL;
> > + errc = ioread32((&(priv->regs)->errc));
> > + if (((errc & CAN_REC) >> 8) > 96)
> > + cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
> > + if ((errc & CAN_TEC) > 96)
> > + cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
> > + dev_warn(&ndev->dev, "%s -> Warning interrupt.\n", __func__);
> > + }
> > + /* Error passive interrupt. */
> > + if (status & PCH_EPASSIV) {
> > + priv->can.can_stats.error_passive++;
> > + priv->can.state = CAN_STATE_ERROR_PASSIVE;
> > + cf->can_id |= CAN_ERR_CRTL;
> > + errc = ioread32((&(priv->regs)->errc));
> > + if (((errc & CAN_REC) >> 8) > 127)
> > + cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
> > + if ((errc & CAN_TEC) > 127)
> > + cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
> > + dev_err(&ndev->dev,
> > + "%s -> Error interrupt.\n", __func__);
> > + }
> > +
> > + if (status & PCH_STUF_ERR)
> > + cf->data[2] |= CAN_ERR_PROT_STUFF;
> > +
> > + if (status & PCH_FORM_ERR)
> > + cf->data[2] |= CAN_ERR_PROT_FORM;
> > +
> > + if (status & PCH_ACK_ERR)
> > + cf->data[2] |= CAN_ERR_PROT_LOC_ACK | CAN_ERR_PROT_LOC_ACK_DEL;
> > +
> > + if ((status & PCH_BIT1_ERR) || (status & PCH_BIT0_ERR))
> > + cf->data[2] |= CAN_ERR_PROT_BIT;
> > +
> > + if (status & PCH_CRC_ERR)
> > + cf->data[2] |= CAN_ERR_PROT_LOC_CRC_SEQ |
> > + CAN_ERR_PROT_LOC_CRC_DEL;
> > +
> > + if (status & PCH_LEC_ALL)
> > + iowrite32(status | PCH_LEC_ALL,
> > +   &(priv->regs)->stat);
>
> A bit-wise test of the above values is wrong, I believe. Please use the
> switch statement instead.
>
> > +
> > + stats->rx_packets++;
> > + stats->rx_bytes += cf->can_dlc;
> > + netif_rx(skb);
> > +}
> > +
> > +static irqreturn_t pch_can_handler(int irq, void *dev_id)
>
> A better name making clear that it's the interrupt handler would be nice.
>
> > +{
> > + u32 int_stat;
> > + u32 reg_stat;
> > + struct net_device *ndev = (struct net_device *)dev_id;
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > + int_stat = pch_can_int_pending(priv);
> > +
> > + if (!int_stat)
> > + return IRQ_NONE;
> > +
> > + if (int_stat == CAN_STATUS_INT) {
> > + reg_stat = ioread32((&(priv->regs)->stat));
> > + if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL | PCH_EWARN |
> > + PCH_EPASSIV)) {
> > + if ((reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL)
> > + pch_can_error(ndev, reg_stat);
> > + }
> > +
> > + /* Recover from Bus Off */
> > + if (!reg_stat && priv->bus_off_interrupt) {
> > + priv->bus_off_interrupt = 0;
> > + pch_can_tx_enable_all(priv);
> > + pch_can_rx_enable_all(priv);
> > +
> > + dev_info(&priv->ndev->dev, "BusOff stage recovered.\n");
>
> Bogus bus-off handling, more later...
>
> > + }
> > +
> > + if (reg_stat & PCH_RX_OK)
> > + pch_can_bit_clear(&(priv->regs)->stat, PCH_RX_OK);
> > +
> > + if (reg_stat & PCH_TX_OK)
> > + pch_can_bit_clear(&(priv->regs)->stat, PCH_TX_OK);
>
> Could be done in one call, I think.
>
> > + int_stat = pch_can_int_pending(priv);
> > + }
> > +
> > + if ((int_stat > 0) && (int_stat <= MAX_MSG_OBJ))
> > + pch_can_msg_obj(ndev, int_stat);
> > +
> > + return IRQ_HANDLED;
> > +}
> > +
> > +static int pch_set_bittiming(struct net_device *ndev)
> > +{
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > + const struct can_bittiming *bt = &priv->can.bittiming;
> > + u32 curr_mode;
> > + u32 reg1; /* CANBIT */
> > + u32 reg2; /* BEPE */
>
> Why not "u32 canbit" then?
>
> > + u32 brp;
> > +
> > + pch_can_get_run_mode(priv, &curr_mode);
> > + if (curr_mode == PCH_CAN_RUN)
> > + pch_can_set_run_mode(priv, PCH_CAN_STOP);
>
> The device is stopped when this function is called. Please remove.
>
> > +
> > + /* Setting the CCE bit for accessing the Can Timing register. */
> > + pch_can_bit_set(&(priv->regs)->cont, CAN_CTRL_CCE);
> > +
> > + brp = (bt->tq) / (1000000/PCH_CAN_CLK) - 1;
> > + reg1 = brp & MSK_BITT_BRP;
> > + reg1 |= (bt->sjw - 1) << BIT_BITT_SJW;
> > + reg1 |= (bt->phase_seg1 + bt->prop_seg - 1) << BIT_BITT_TSEG1;
> > + reg1 |= (bt->phase_seg2 - 1) << BIT_BITT_TSEG2;
> > + reg2 = (brp & MSK_BRPE_BRPE) >> BIT_BRPE_BRPE;
> > + iowrite32(reg1, (&(priv->regs)->bitt));
> > + iowrite32(reg2, (&(priv->regs)->brpe));
> > + pch_can_bit_clear(&(priv->regs)->cont, CAN_CTRL_CCE);
> > +
> > + if (curr_mode == PCH_CAN_RUN)
> > + pch_can_set_run_mode(priv, PCH_CAN_RUN);
>
> Ditto.
>
> > + return 0;
> > +}
> > +
> > +static void pch_can_start(struct net_device *ndev)
> > +{
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > +
> > + if (priv->can.state != CAN_STATE_STOPPED)
> > + pch_can_reset(priv);
> > +
> > + pch_set_bittiming(ndev);
> > + pch_can_set_optmode(priv);
> > + priv->can.state = CAN_STATE_ERROR_ACTIVE;
>
> Hm, where do you really start the controller. I'm missing
> pch_can_set_run_mode(priv, PCH_CAN_RUN).
>
> > + return;
> > +}
> > +
> > +static int pch_can_do_set_mode(struct net_device *ndev, enum can_mode mode)
> > +{
> > + int ret = 0;
> > +
> > + switch (mode) {
> > + case CAN_MODE_START:
> > + pch_can_start(ndev);
> > + netif_wake_queue(ndev);
> > + break;
> > + default:
> > + ret = -EOPNOTSUPP;
> > + break;
> > + }
> > +
> > + return ret;
> > +}
>
> Note that this function is called when the device will recover from bus-off.
>
> > +static int pch_can_get_state(const struct net_device *ndev,
> > +      enum can_state *state)
> > +{
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > +
> > + *state = priv->can.state;
> > + return 0;
> > +}
>
> There is no need for that function as the driver handles state changes
> in the interrupt handler.
>
> > +static int pch_open(struct net_device *ndev)
>
> That's confussing! Please use the prefix pch_can throught this file.
>
> > +{
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > + int retval;
> > +
> > + pch_can_open(priv);
>
> This function already starts the controller, which is too *early*.
>
> > +
> > + retval = pci_enable_msi(priv->dev);
> > + if (retval) {
> > + dev_err(&ndev->dev, "Unable to allocate MSI ret=%d\n", retval);
> > + goto pci_en_msi_err;
> > + }
> > +
> > + /* Regsitering the interrupt. */
> > + retval = request_irq(priv->dev->irq, pch_can_handler, IRQF_SHARED,
> > +      ndev->name, ndev);
> > + if (retval) {
> > + dev_err(&ndev->dev, "request_irq failed.\n");
> > + goto req_irq_err;
> > + }
> > +
> > + /* Assuming that no bus off interrupt. */
> > + priv->bus_off_interrupt = 0;
> > +
> > + /* Open common can device */
> > + retval = open_candev(ndev);
> > + if (retval) {
> > + dev_err(ndev->dev.parent, "open_candev() failed %d\n", retval);
> > + goto err_open_candev;
> > + }
> > +
> > + pch_can_start(ndev);
>
> Thde above function should finally start the controller.
>
> > + netif_start_queue(ndev);
> > +
> > + return 0;
> > +
> > +err_open_candev:
> > + free_irq(priv->dev->irq, ndev);
> > +req_irq_err:
> > + pci_disable_msi(priv->dev);
> > +pci_en_msi_err:
> > + pch_can_release(priv);
> > +
> > + return retval;
> > +}
> > +
> > +static int pch_close(struct net_device *ndev)
> > +{
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > +
> > + netif_stop_queue(ndev);
> > + pch_can_release(priv);
> > + free_irq(priv->dev->irq, ndev);
> > + pci_disable_msi(priv->dev);
> > + close_candev(ndev);
> > + priv->can.state = CAN_STATE_STOPPED;
> > + return 0;
> > +}
> > +
> > +static int pch_get_free_msg_obj(struct net_device *ndev)
> > +{
> > + u32 buffer_status = 0;
> > + u32 tx_disable_counter = 0;
> > + u32 tx_buffer_avail = 0;
> > + u32 status;
> > + s32 i;
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > +
> > + /* Getting the message object status. */
> > + buffer_status = (u32) pch_can_get_buffer_status(priv);
> > +
> > + /* Getting the free transmit message object. */
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if ((priv->msg_obj[i] == MSG_OBJ_TX)) {
> > + /* Checking whether the object is enabled. */
> > + pch_can_get_tx_enable(priv, i + 1, &status);
> > + if (status == ENABLE) {
> > + if (!((buffer_status >> i) & 1)) {
> > + tx_buffer_avail = (i + 1);
> > + break;
> > + }
> > + } else {
> > + tx_disable_counter++;
> > + }
> > + }
> > + }
> > +
> > + /* If no transmit object available. */
> > + if (!tx_buffer_avail) {
> > + /* If no object is enabled. */
> > + if ((tx_disable_counter == PCH_TX_OBJ_NUM)) {
> > + dev_err(&ndev->dev, "All tx buffers are disabled.\n");
> > + return -EPERM;
> > + } else {
> > + dev_err(&ndev->dev, "%s:No tx buf free.\n", __func__);
> > + return -PCH_CAN_NO_TX_BUFF;
> > + }
> > + }
> > + return tx_buffer_avail;
> > +}
> > +
> > +static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
> > +{
> > + canid_t id;
> > + u32 id1 = 0;
> > + u32 id2 = 0;
>
> Need these values to be preset?
>
> > + u32 run_mode;
> > + u32 i, j;
>
> It's common to use type "int" for the usual incrementer value... as you
> do in other places as well. Please check!
>
> > + unsigned long flags;
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > + struct can_frame *cf = (struct can_frame *)skb->data;
> > + struct net_device_stats *stats = &ndev->stats;
> > + u32 tx_buffer_avail = 0;
> > +
> > + if (can_dropped_invalid_skb(ndev, skb))
> > + return NETDEV_TX_OK;
> > +
> > + /* Getting the current CAN mode. */
> > + pch_can_get_run_mode(priv, &run_mode);
> > + if (run_mode != PCH_CAN_RUN) {
> > + dev_err(&ndev->dev, "CAN stopped on transmit attempt.\n");
> > + return -EPERM;
> > + }
>
> Can this happen? I think this check can be removed. Anyway, -EPERM is
> not a valid return value for that function.
>
> > +
> > + tx_buffer_avail = pch_get_free_msg_obj(ndev);
> > + if (tx_buffer_avail < 0)
> > + return tx_buffer_avail;
>
> Wrong return value?
>
> > +
> > + /* Attaining the lock. */
> > + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> > +
> > + /* Reading the Msg Obj from the Msg RAM to the Interface register. */
> > + iowrite32(CAN_CMASK_RX_TX_GET, &(priv->regs)->if1_cmask);
> > + pch_can_check_if1_busy(priv, tx_buffer_avail);
> > +
> > + /* Setting the CMASK register. */
> > + pch_can_bit_set(&(priv->regs)->if1_cmask, CAN_CMASK_ALL);
> > +
> > + /* If ID extended is set. */
> > + if (cf->can_id & CAN_EFF_FLAG) {
> > + id =  cf->can_id & CAN_EFF_MASK;
> > + id1 = id & 0xffff;
> > + id2 = ((id & (0x1fff << 16)) >> 16) | CAN_ID2_XTD;
>
> Please use some more macro definitions for the sake of readability.
>
> > + } else {
> > + id =  cf->can_id & CAN_SFF_MASK;
> > + id1 = 0;
> > + id2 = ((id & CAN_SFF_MASK) << 2);
> > + }
> > + pch_can_bit_clear(&(priv->regs)->if1_id1, 0xffff);
> > + pch_can_bit_clear(&(priv->regs)->if1_id2, 0x1fff | CAN_ID2_XTD);
> > + pch_can_bit_set(&(priv->regs)->if1_id1, id1);
> > + pch_can_bit_set(&(priv->regs)->if1_id2, id2);
> > +
> > + /* If remote frame has to be transmitted.. */
> > + if (cf->can_id & CAN_RTR_FLAG)
> > + pch_can_bit_clear(&(priv->regs)->if1_id2, CAN_ID2_DIR);
> > +
> > + for (i = 0, j = 0; i < cf->can_dlc; j++) {
> > + iowrite32(le32_to_cpu(cf->data[i++]),
> > + (&(priv->regs)->if1_dataa1) + j*4);
> > + if (i == cf->can_dlc)
> > + break;
> > + iowrite32(le32_to_cpu(cf->data[i++] << 8),
> > + (&(priv->regs)->if1_dataa1) + j*4);
> > + }
> > + can_put_echo_skb(skb, ndev, 0);
> > +
> > + /* Updating the size of the data. */
> > + pch_can_bit_clear(&(priv->regs)->if1_mcont, 0x0f);
> > + pch_can_bit_set(&(priv->regs)->if1_mcont, cf->can_dlc);
> > +
> > + /* Clearing IntPend, NewDat & TxRqst */
> > + pch_can_bit_clear(&(priv->regs)->if1_mcont,
> > +    (CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
> > +     CAN_IF_MCONT_TXRQXT));
> > +
> > + /* Setting NewDat, TxRqst bits */
> > + pch_can_bit_set(&(priv->regs)->if1_mcont,
> > + (CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_TXRQXT));
> > +
> > + pch_can_check_if1_busy(priv, tx_buffer_avail);
> > + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> > +
> > + stats->tx_bytes += cf->can_dlc;
> > + stats->tx_packets++;
>
> That shoould be incremented when the TX done interrupt is handled.
>
> > +
> > + return NETDEV_TX_OK;
> > +}
> > +
> > +static const struct net_device_ops pch_can_netdev_ops = {
> > + .ndo_open = pch_open,
> > + .ndo_stop = pch_close,
> > + .ndo_start_xmit = pch_xmit,
> > +};
> > +
> > +static void __devexit pch_can_remove(struct pci_dev *pdev)
> > +{
> > + struct net_device *ndev = pci_get_drvdata(pdev);
> > + struct pch_can_priv *priv = netdev_priv(ndev);
> > +
> > + unregister_candev(priv->ndev);
> > + free_candev(priv->ndev);
> > + pci_iounmap(pdev, priv->base);
> > + pci_release_regions(pdev);
> > + pci_disable_device(pdev);
> > + pci_set_drvdata(pdev, NULL);
> > + pch_can_reset(priv);
> > +}
> > +
> > +#ifdef CONFIG_PM
> > +static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
> > +{
> > + int i; /* Counter variable. */
> > + int retval; /* Return value. */
> > + u32 buf_stat; /* Variable for reading the transmit buffer status. */
> > + u32 counter = 0xFFFFFF;
> > +
> > + struct net_device *dev = pci_get_drvdata(pdev);
> > + struct pch_can_priv *priv = netdev_priv(dev);
> > +
> > + /* Stop the CAN controller */
> > + pch_can_set_run_mode(priv, PCH_CAN_STOP);
> > +
> > + /* Indicate that we are aboutto/in suspend */
> > + priv->can.state = CAN_STATE_SLEEPING;
> > +
> > + /* Waiting for all transmission to complete. */
> > + while (counter) {
> > + buf_stat = pch_can_get_buffer_status(priv);
> > + if (!buf_stat)
> > + break;
> > + counter--;
> > + }
> > + if (!counter)
> > + dev_err(&pdev->dev, "%s -> Transmission time out.\n", __func__);
>
> Timeout without defined delay!
>
> > + /* Save interrupt configuration and then disable them */
> > + pch_can_get_int_enables(priv, &(priv->int_enables));
> > + pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
> > +
> > + /* Save Tx buffer enable state */
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_TX)
> > + pch_can_get_tx_enable(priv, (i + 1),
> > +       &(priv->tx_enable[i]));
> > + }
> > +
> > + /* Disable all Transmit buffers */
> > + pch_can_tx_disable_all(priv);
> > +
> > + /* Save Rx buffer enable state */
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_RX) {
> > + pch_can_get_rx_enable(priv, (i + 1),
> > + &(priv->rx_enable[i]));
> > + pch_can_get_rx_buffer_link(priv, (i + 1),
> > + &(priv->rx_link[i]));
> > + }
> > + }
> > +
> > + /* Disable all Receive buffers */
> > + pch_can_rx_disable_all(priv);
> > + retval = pci_save_state(pdev);
> > + if (retval) {
> > + dev_err(&pdev->dev, "pci_save_state failed.\n");
> > + } else {
> > + pci_enable_wake(pdev, PCI_D3hot, 0);
> > + pci_disable_device(pdev);
> > + pci_set_power_state(pdev, pci_choose_state(pdev, state));
> > + }
> > +
> > + return retval;
> > +}
> > +
> > +static int pch_can_resume(struct pci_dev *pdev)
> > +{
> > + int i; /* Counter variable. */
> > + int retval; /* Return variable. */
> > + struct net_device *dev = pci_get_drvdata(pdev);
> > + struct pch_can_priv *priv = netdev_priv(dev);
> > +
> > + pci_set_power_state(pdev, PCI_D0);
> > + pci_restore_state(pdev);
> > + retval = pci_enable_device(pdev);
> > + if (retval) {
> > + dev_err(&pdev->dev, "pci_enable_device failed.\n");
> > + return retval;
> > + }
> > +
> > + pci_enable_wake(pdev, PCI_D3hot, 0);
> > +
> > + priv->can.state = CAN_STATE_ERROR_ACTIVE;
> > +
> > + /* Disabling all interrupts. */
> > + pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
> > +
> > + /* Setting the CAN device in Stop Mode. */
> > + pch_can_set_run_mode(priv, PCH_CAN_STOP);
> > +
> > + /* Configuring the transmit and receive buffers. */
> > + pch_can_config_rx_tx_buffers(priv);
> > +
> > + /* Restore the CAN state */
> > + pch_set_bittiming(dev);
> > +
> > + /* Listen/Active */
> > + pch_can_set_optmode(priv);
> > +
> > + /* Enabling the transmit buffer. */
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_TX) {
> > + pch_can_set_tx_enable(priv, i + 1,
> > +       priv->tx_enable[i]);
> > + }
> > + }
> > +
> > + /* Configuring the receive buffer and enabling them. */
> > + for (i = 0; i < PCH_OBJ_NUM; i++) {
> > + if (priv->msg_obj[i] == MSG_OBJ_RX) {
> > + /* Restore buffer link */
> > + pch_can_set_rx_buffer_link(priv, i + 1,
> > +    priv->rx_link[i]);
> > +
> > + /* Restore buffer enables */
> > + pch_can_set_rx_enable(priv, i + 1, priv->rx_enable[i]);
> > + }
> > + }
> > +
> > + /* Enable CAN Interrupts */
> > + pch_can_set_int_custom(priv);
> > +
> > + /* Restore Run Mode */
> > + pch_can_set_run_mode(priv, PCH_CAN_RUN);
> > +
> > + return retval;
> > +}
>
> Are the suspend and resume functions tested?
>
> > +#else
> > +#define pch_can_suspend NULL
> > +#define pch_can_resume NULL
> > +#endif
>
> Add empty line here
>
> > +static int __devinit pch_can_probe(struct pci_dev *pdev,
> > +    const struct pci_device_id *id)
> > +{
> > + struct net_device *ndev;
> > + struct pch_can_priv *priv;
> > + int rc;
> > + int index;
> > + void __iomem *addr;
> > +
> > + rc = pci_enable_device(pdev);
> > + if (rc) {
> > + dev_err(&pdev->dev, "Failed pci_enable_device %d\n", rc);
> > + goto probe_exit_endev;
> > + }
> > +
> > + rc = pci_request_regions(pdev, KBUILD_MODNAME);
> > + if (rc) {
> > + dev_err(&pdev->dev, "Failed pci_request_regions %d\n", rc);
> > + goto probe_exit_pcireq;
> > + }
> > +
> > + addr = pci_iomap(pdev, 1, 0);
> > + if (!addr) {
> > + rc = -EIO;
> > + dev_err(&pdev->dev, "Failed pci_iomap\n");
> > + goto probe_exit_ipmap;
> > + }
> > +
> > + ndev = alloc_candev(sizeof(struct pch_can_priv), 1);
> > + if (!ndev) {
> > + rc = -ENOMEM;
> > + dev_err(&pdev->dev, "Failed alloc_candev\n");
> > + goto probe_exit_alloc_candev;
> > + }
> > +
> > + priv = netdev_priv(ndev);
> > + priv->ndev = ndev;
> > + priv->base = addr;
> > + priv->regs = addr;
> > + priv->dev = pdev;
> > + priv->can.bittiming_const = &pch_can_bittiming_const;
> > + priv->can.do_set_mode = pch_can_do_set_mode;
> > + priv->can.do_get_state = pch_can_get_state;
>
> Not needed! See above.
>
> Could you please also implement do_get_berr_counter().
>
> > + priv->can.ctrlmode_supported = CAN_CTRLMODE_LISTENONLY |
> > +        CAN_CTRLMODE_LOOPBACK;
> > + ndev->irq = pdev->irq;
> > + ndev->flags |= IFF_ECHO;
> > +
> > + pci_set_drvdata(pdev, ndev);
> > + SET_NETDEV_DEV(ndev, &pdev->dev);
> > + ndev->netdev_ops = &pch_can_netdev_ops;
> > +
> > + priv->can.clock.freq = PCH_CAN_CLK * 1000; /* Hz to KHz) */
> > + for (index = 0; index < PCH_RX_OBJ_NUM;)
> > + priv->msg_obj[index++] = MSG_OBJ_RX;
> > +
> > + for (index = index;  index < PCH_OBJ_NUM;)
> > + priv->msg_obj[index++] = MSG_OBJ_TX;
> > +
> > + rc = register_candev(ndev);
> > + if (rc) {
> > + dev_err(&pdev->dev, "Failed register_candev %d\n", rc);
> > + goto probe_exit_reg_candev;
> > + }
> > +
> > + return 0;
> > +
> > +probe_exit_reg_candev:
> > + free_candev(ndev);
> > +probe_exit_alloc_candev:
> > + pci_iounmap(pdev, addr);
> > +probe_exit_ipmap:
> > + pci_release_regions(pdev);
> > +probe_exit_pcireq:
> > + pci_disable_device(pdev);
> > +probe_exit_endev:
> > + return rc;
> > +}
> > +
> > +static struct pci_driver pch_can_pcidev = {
> > + .name = KBUILD_MODNAME,
> > + .id_table = pch_can_pcidev_id,
> > + .probe = pch_can_probe,
> > + .remove = __devexit_p(pch_can_remove),
> > + .suspend = pch_can_suspend,
> > + .resume = pch_can_resume,
> > +};
> > +
> > +static int __init pch_can_pci_init(void)
> > +{
> > + return pci_register_driver(&pch_can_pcidev);
> > +}
> > +module_init(pch_can_pci_init);
> > +
> > +static void __exit pch_can_pci_exit(void)
> > +{
> > + pci_unregister_driver(&pch_can_pcidev);
> > +}
> > +module_exit(pch_can_pci_exit);
> > +
> > +MODULE_DESCRIPTION("Controller Area Network Driver");
> > +MODULE_LICENSE("GPL");
>
> GPL v2 ?
>
> > +MODULE_VERSION("0.94");
> > +MODULE_DEVICE_TABLE(pci, pch_can_pcidev_id);
>
> Please add it below the declaration of pch_can_pcidev_id.
>
> In this driver you are using just *one* RX object. This means that the
> CPU must handle new messages as quickly as possible otherwise message
> losses will happen, right?. For sure, this will not make user's happy.
> Any chance to use more RX objects in FIFO mode?
>
> Thanks,
>
> Wolfgang.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
