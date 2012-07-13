From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v3] tg3: add device id of Apple Thunderbolt Ethernet
 device
Date: Fri, 13 Jul 2012 00:06:38 -0700
Message-ID: <1342163198.7472.73.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <20120712202131.GA26436@kroah.com>
 <20120712205607.GA27999@kroah.com> <20120713013944.GB6445@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>, netdev@vger.kernel.org
To: "Greg KH" <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2150 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752980Ab2GMHGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 03:06:50 -0400
In-Reply-To: <20120713013944.GB6445@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 18:39 -0700, Greg KH wrote: 
> The Apple Thunderbolt ethernet device is already listed in the driver,
> but not hooked up in the MODULE_DEVICE_TABLE().  This fixes that and
> allows it to work properly.
> 
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> 
> ---
> Resent to Cc: the proper developers this time.
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index e47ff8b..3721833 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -298,6 +298,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
>  	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795)},
>  	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5719)},
>  	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5720)},
> +	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57762)},
>  	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
>  	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
>  	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
> 

ACK for net-next.  I don't know why Matt added everything to support
this chip except the entry in the PCI ID table.

Acked-by: Michael Chan <mchan@broadcom.com>
