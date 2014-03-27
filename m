From: Appana Durga Kedareswara Rao <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH v6] can: xilinx CAN controller support
Date: Thu, 27 Mar 2014 14:20:58 +0000
Message-ID: <8cbdd3af-afb3-4a2d-a4b7-38ce4e34b73d@TX2EHSMHS018.ehs.local>
References: <5ff46a21-3047-40ff-9221-f08e476f9ce6@VA3EHSMHS030.ehs.local>
 <1395812357.3726.14.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	"mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1395812357.3726.14.camel@joe-AO722>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Joe perches,


> -----Original Message-----
> From: Joe Perches [mailto:joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org]
> Sent: Wednesday, March 26, 2014 11:09 AM
> To: Appana Durga Kedareswara Rao
> Cc: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org; mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org; Michal Simek;
> grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org; linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Appana Durga
> Kedareswara Rao
> Subject: Re: [PATCH v6] can: xilinx CAN controller support
>
> On Wed, 2014-03-26 at 10:56 +0530, Kedareswara rao Appana wrote:
> > This patch adds xilinx CAN controller support.
> > This driver supports both ZYNQ CANPS and Soft IP AXI CAN controller.
>
> Just trivial notes about dmesg logging output.
>
> > diff --git a/drivers/net/can/xilinx_can.c
> > b/drivers/net/can/xilinx_can.c
> []
> > +static int set_reset_mode(struct net_device *ndev) {
> []
> > +                   netdev_warn(ndev, "timedout waiting for config
> mode\n");
>
> timed out
>
OK will do

> > +static int xcan_set_bittiming(struct net_device *ndev) {
> []
> > +   if (!is_config_mode) {
> > +           netdev_alert(ndev,
> > +                   "BUG! Cannot set bittiming can is notin config
> mode\n");
>
> "Cannot set bit timing - CAN is not in config mode\n"
>
> > +static int xcan_chip_start(struct net_device *ndev) {
>
> > +                   netdev_warn(ndev,
> > +                           "time out waiting for correct mode\n");
>
> Please be consistent.  Maybe
> "timed out waiting for correct mode\n"
>
Ok Will change.

> > +static int xcan_open(struct net_device *ndev) {
> > +   struct xcan_priv *priv = netdev_priv(ndev);
> > +   int ret;
> > +
> > +   ret = request_irq(ndev->irq, xcan_interrupt, priv->irq_flags,
> > +                   ndev->name, ndev);
> > +   if (ret < 0) {
> > +           netdev_err(ndev, "Irq allocation for CAN failed\n");
>
> irq is almost always lower case.
>
Ok Will change.

Regards,
Kedar.

>



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
