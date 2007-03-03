From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [USBNET] DM9501: Add Corega FEther USB-TXC support.
Date: Fri, 02 Mar 2007 20:33:55 -0500
Message-ID: <45E8D083.3010907@garzik.org>
References: <20070301.164454.14331566.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55766 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992826AbXCCBd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:33:59 -0500
In-Reply-To: <20070301.164454.14331566.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  drivers/usb/net/dm9601.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/usb/net/dm9601.c b/drivers/usb/net/dm9601.c
> index 4a932e1..c0bc52b 100644
> --- a/drivers/usb/net/dm9601.c
> +++ b/drivers/usb/net/dm9601.c
> @@ -571,6 +571,10 @@ static const struct driver_info dm9601_info =3D =
{
> =20
>  static const struct usb_device_id products[] =3D {
>  	{
> +	 USB_DEVICE(0x07aa, 0x9601),	/* Corega FEther USB-TXC */
> +	 .driver_info =3D (unsigned long)&dm9601_info,
> +	 },
> +	{


ACK the patch, though I wonder if this shouldn't instead go to Greg.

Honestly, I would prefer that the USB net drivers were moved into=20
drivers/net with the other net drivers, /then/ I would merge such=20
patches.  We don't add drivers for PCI-based hardware to=20
drivers/pci/net, after all...

