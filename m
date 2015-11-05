From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH v2] USB: qmi_wwan: Add quirk for Quectel EC20 Mini PCIe module
Date: Thu, 05 Nov 2015 15:08:07 +0100
Message-ID: <87ziys8rp4.fsf@nemi.mork.no>
References: <1446720952-15635-1-git-send-email-ynezz@true.cz>
	<1446724501-18821-1-git-send-email-ynezz@true.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Petr =?utf-8?Q?=C5=A0tetiar?= <ynezz-knWk7/PSn+s@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1446724501-18821-1-git-send-email-ynezz-knWk7/PSn+s@public.gmane.org> ("Petr
	=?utf-8?Q?=C5=A0tetiar=22's?= message of "Thu, 5 Nov 2015 12:55:01 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Petr =C5=A0tetiar <ynezz-knWk7/PSn+s@public.gmane.org> writes:

> This device has same vendor and product IDs as G2K devices, but it ha=
s
> different number of interfaces(4 vs 5) and also different interface
> layout where EC20 has QMI on interface 4 instead of 0.
>
> lsusb output:
>
> 	Bus 002 Device 003: ID 05c6:9215 Qualcomm, Inc. Acer Gobi 2000
> 	Device Descriptor:
> 	  bLength                18
> 	  bDescriptorType         1
> 	  bcdUSB               2.00
> 	  bDeviceClass            0 (Defined at Interface level)
> 	  bDeviceSubClass         0
> 	  bDeviceProtocol         0
> 	  bMaxPacketSize0        64
> 	  idVendor           0x05c6 Qualcomm, Inc.
> 	  idProduct          0x9215 Acer Gobi 2000 Wireless Modem
> 	  bcdDevice            2.32
> 	  iManufacturer           1 Quectel
> 	  iProduct                2 Quectel LTE Module
> 	  iSerial                 0
> 	  bNumConfigurations      1
> 	  Configuration Descriptor:
> 	    bLength                 9
> 	    bDescriptorType         2
> 	    wTotalLength          209
> 	    bNumInterfaces          5
> 	    bConfigurationValue     1
> 	    iConfiguration          0
> 	    bmAttributes         0xa0
> 	      (Bus Powered)
> 	      Remote Wakeup
> 	    MaxPower              500mA
>
> Signed-off-by: Petr =C5=A0tetiar <ynezz-knWk7/PSn+s@public.gmane.org>

This looks good to me. =20

Acked-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
