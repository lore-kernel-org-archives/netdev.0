From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: removed USB_USBNET as a config option
Date: Mon, 19 Oct 2015 21:16:37 +0200
Message-ID: <87oafuu0ru.fsf@nemi.mork.no>
References: <1445257387-4278-1-git-send-email-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57203 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbbJSTQu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 15:16:50 -0400
In-Reply-To: <1445257387-4278-1-git-send-email-oneukum@suse.com> (Oliver
	Neukum's message of "Mon, 19 Oct 2015 14:23:07 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.com> writes:

> usbnet drives no devices of its own. It makes more sense to
> select it whenever a driver for actual hardware that needs
> it is chosen rather than offer it as an option of its own.
>
> Signed-off-by: Oliver Neukum <oneukum@suse.com>
> ---
>  drivers/net/usb/Kconfig | 75 +++++++++++++++------------------------=
----------
>  1 file changed, 23 insertions(+), 52 deletions(-)
>
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 8cf0eba..0cf45ab 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -119,42 +119,12 @@ config USB_LAN78XX
>  	  module will be called lan78xx.
> =20

This looks incomplete.

bjorn@nemi:/usr/local/src/git/linux$ git am /tmp/f
Applying: usbnet: removed USB_USBNET as a config option
bjorn@nemi:/usr/local/src/git/linux$ git grep -B4 'depends on USB_USBNE=
T'
drivers/net/usb/Kconfig-            * Ericsson F5521gw Mobile Broadband=
 Module
drivers/net/usb/Kconfig-
drivers/net/usb/Kconfig-config USB_NET_HUAWEI_CDC_NCM
drivers/net/usb/Kconfig-        tristate "Huawei NCM embedded AT channe=
l support"
drivers/net/usb/Kconfig:        depends on USB_USBNET
--
drivers/net/usb/Kconfig-                called huawei_cdc_ncm.ko.
drivers/net/usb/Kconfig-
drivers/net/usb/Kconfig-config USB_NET_CDC_MBIM
drivers/net/usb/Kconfig-        tristate "CDC MBIM support"
drivers/net/usb/Kconfig:        depends on USB_USBNET
--
drivers/net/usb/Kconfig-          adapters marketed under the DeLOCK br=
and.
drivers/net/usb/Kconfig-
drivers/net/usb/Kconfig-config USB_NET_RNDIS_HOST
drivers/net/usb/Kconfig-        tristate "Host for RNDIS and ActiveSync=
 devices"
drivers/net/usb/Kconfig:        depends on USB_USBNET
--
drivers/net/usb/Kconfig-          with one of these chips.
drivers/net/usb/Kconfig-
drivers/net/usb/Kconfig-config USB_NET_ZAURUS
drivers/net/usb/Kconfig-        tristate "Sharp Zaurus (stock ROMs) and=
 compatible"
drivers/net/usb/Kconfig:        depends on USB_USBNET
--
drivers/net/usb/Kconfig-          module will be called kalmia.
drivers/net/usb/Kconfig-
drivers/net/usb/Kconfig-config USB_NET_QMI_WWAN
drivers/net/usb/Kconfig-        tristate "QMI WWAN driver for Qualcomm =
MSM based 3G and LTE modems"
drivers/net/usb/Kconfig:        depends on USB_USBNET



Bj=C3=B8rn
