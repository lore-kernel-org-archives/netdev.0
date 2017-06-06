From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH v2 4/4] net: macb: Add hardware PTP support
Date: Tue, 6 Jun 2017 08:54:50 +0000
Message-ID: <BN3PR07MB251673623B941CAF5DEAB474C9CB0@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
 <1496413690-22826-1-git-send-email-rafalo@cadence.com>
 <20170604205516.GA7848@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "andrei.pistirica@microchip.com" <andrei.pistirica@microchip.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170604205516.GA7848@localhost.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: 4 czerwca 2017 22:55
> To: Rafal Ozieblo <rafalo@cadence.com>
> Cc: David Miller <davem@davemloft.net>; nicolas.ferre@atmel.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
> harini.katakam@xilinx.com; andrei.pistirica@microchip.com
> Subject: Re: [PATCH v2 4/4] net: macb: Add hardware PTP support
>=20
> On Fri, Jun 02, 2017 at 03:28:10PM +0100, Rafal Ozieblo wrote:
>=20
> > +int gem_get_hwtst(struct net_device *dev, struct ifreq *rq)
> > +{
> > +	struct macb *bp =3D netdev_priv(dev);
> > +	struct hwtstamp_config *tstamp_config =3D &bp->tstamp_config;
> > +
> > +	if ((bp->hw_dma_cap & HW_DMA_CAP_PTP) =3D=3D 0)
> > +		return -EFAULT;
>=20
> Segmentation fault?  Really?
>=20
> ...
>=20
> > +int gem_set_hwtst(struct net_device *dev, struct ifreq *ifr, int cmd)
> > +{
> > +	struct macb *bp =3D netdev_priv(dev);
> > +	struct hwtstamp_config *tstamp_config =3D &bp->tstamp_config;
> > +	enum macb_bd_control tx_bd_control =3D TSTAMP_DISABLED;
> > +	enum macb_bd_control rx_bd_control =3D TSTAMP_DISABLED;
> > +	u32 regval;
> > +
> > +	if ((bp->hw_dma_cap & HW_DMA_CAP_PTP) =3D=3D 0)
> > +		return -EFAULT;
>=20
> here again
Would "ENOTSUP" be sufficient ?

>=20
> Thanks,
> Richard

Regards,
Rafal
