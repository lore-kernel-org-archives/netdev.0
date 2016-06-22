From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Wed, 22 Jun 2016 22:11:17 +0000
Message-ID: <c1292dba89864fd0a931aa160aaed7eb@ausx13mpc124.AMER.DELL.COM>
References: <201606141828.10969@pali>	<20160614164017.GB14477@kroah.com>
	<201606141847.36109@pali>
 <20160614.143521.2085426866285759820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gregkh@linuxfoundation.org>, <andrew@lunn.ch>,
	<hayeswang@realtek.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<anthony.wong@canonical.com>
To: <davem@davemloft.net>, <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Limonciello, Mario
> Sent: Tuesday, June 14, 2016 5:27 PM
> To: 'David Miller' <davem@davemloft.net>; pali.rohar@gmail.com
> Cc: gregkh@linuxfoundation.org; andrew@lunn.ch;
> hayeswang@realtek.com; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; linux-usb@vger.kernel.org;
> anthony.wong@canonical.com
> Subject: RE: [PATCH v6] r8152: Add support for setting pass through M=
AC
> address on RTL8153-AD
>=20
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Tuesday, June 14, 2016 1:35 PM
> > To: pali.rohar@gmail.com
> > Cc: gregkh@linuxfoundation.org; andrew@lunn.ch; Limonciello, Mario
> > <Mario_Limonciello@Dell.com>; hayeswang@realtek.com; linux-
> > kernel@vger.kernel.org; netdev@vger.kernel.org; linux-
> > usb@vger.kernel.org; anthony.wong@canonical.com
> > Subject: Re: [PATCH v6] r8152: Add support for setting pass through=
 MAC
> > address on RTL8153-AD
> >
> > From: Pali Roh=E1r <pali.rohar@gmail.com>
> > Date: Tue, 14 Jun 2016 18:47:36 +0200
> >
> > > You have never seen two ethernet cards with same MAC addresses?
> Right
> > I
> > > have not seen two USB, but there is non zero chance that could ha=
ppen.
> >
> > It would be an error scenerio, and something to be avoided.
> >
> > It is a valid and correct assumption that one is able to put
> > several devices at the same time on the same physical network
> > and expect it to work.
> >
> > The behavior added by the change in question invalidates that.
> >
> > I'm trying to consider the long term aspects of this, which is that=
 if
> > more devices adopt this scheme we're in trouble if we blindly
> > interpret the MAC address in this way.
> >
>=20
> Do you mean if other manufacturers start to ship devices with
> RTL8135-AD's w/ this pass through bit set and people start to try to
> mix and match?
>=20
> > This firmware MAC property facility seems to be designed with only =
an
> > extremely narrow use case being considered.
>=20
> Yes, as I understand it this is the reason that it's only on such spe=
cific devices
> that the mac address pass through bit is actually set on the efuse.

David,

Did you have any more thoughts about this?  I'm happy to make some othe=
r
adjustments to the patch, if you have some recommendations.
