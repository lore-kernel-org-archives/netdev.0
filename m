From: Roland Dreier <roland@purestorage.com>
Subject: Re: [PATCH v3] tg3: add device id of Apple Thunderbolt Ethernet device
Date: Thu, 12 Jul 2012 22:33:26 -0700
Message-ID: <CAL1RGDUK=q+_d2hnWbALde6602d92=x7+T7FUY1zPL8AtUcXcQ@mail.gmail.com>
References: <20120712202131.GA26436@kroah.com> <20120712205607.GA27999@kroah.com>
 <20120713013944.GB6445@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog105.obsmtp.com ([74.125.245.78]:52656 "HELO
	na3sys010aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755722Ab2GMFds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 01:33:48 -0400
Received: by qabj40 with SMTP id j40so183985qab.1
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 22:33:46 -0700 (PDT)
In-Reply-To: <20120713013944.GB6445@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 6:39 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
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
>         {PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795)},
>         {PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5719)},
>         {PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5720)},
> +       {PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57762)},
>         {PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
>         {PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
>         {PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},

I realize there's no way Greg can know the answer to this or test the
corresponding change...

But for the Broadcom guys:
it looks like there simiarly is code in the driver for at least

TG3PCI_DEVICE_TIGON3_57766
TG3PCI_DEVICE_TIGON3_57782
TG3PCI_DEVICE_TIGON3_57786

without entries in the PCI device table.  Should those similarly be added?

 - R.
