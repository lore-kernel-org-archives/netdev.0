From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next v2 6/6] r8152: support RTL8153
Date: Fri, 3 Jan 2014 10:56:02 +0800
Message-ID: <605671F106F540BA9665A195CACB78A0@realtek.com.tw>
References: <1388632963-1341-1-git-send-email-hayeswang@realtek.com><1388633110-1435-1-git-send-email-hayeswang@realtek.com> <877gai8nqu.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <oliver@neukum.org>, <netdev@vger.kernel.org>,
	'nic_swsd' <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: =?iso-8859-1?Q?'Bj=F8rn_Mork'?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877gai8nqu.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Bj=F8rn Mork [mailto:bjorn@mork.no]=20
> Sent: Thursday, January 02, 2014 10:25 PM
> To: Hayeswang
> Cc: oliver@neukum.org; netdev@vger.kernel.org; nic_swsd;=20
> linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org
> Subject: Re: [PATCH net-next v2 6/6] r8152: support RTL8153
>=20
[...]
> > +#if defined(CONFIG_USB_RTL8152) ||=20
> defined(CONFIG_USB_RTL8152_MODULE)
> > +/* Samsung USB Ethernet Adapters */
> > +{
> > +	USB_DEVICE_AND_INTERFACE_INFO(SAMSUNG_VENDOR_ID,=20
> 0xa101, USB_CLASS_COMM,
> > +			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
> > +	.driver_info =3D 0,
> > +},
> > +#endif
>=20
>=20
> We don't play the if-other-driver-is-enabled for any other of the
> blacklisted devices, including other devices supported by the RTL8152
> driver.  Why do we need it here?

The USB nic have two configurations. One is the config 2 which is the E=
CM
mode and uses the driver of cdc_ether. The other is the config 1 which =
use
the driver of r8152. When the dangle is plugged, I find the configurati=
on
is 2 and the ECM driver would be loaded. By this way, you could select
which mode you want to run. Some people would select ECM mode for
performance, and the other would select r8152 for power saving.
=20
Best Regards,
Hayes
