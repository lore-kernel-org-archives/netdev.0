From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH] tg3: Add BCM57766 to PCI device table
Date: Fri, 8 Feb 2013 10:27:14 -0800
Message-ID: <51154382.2090407@broadcom.com>
References: <1360279864-8732-1-git-send-email-j.de.gram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: "Joerie de Gram" <j.de.gram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2157 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946611Ab3BHS3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 13:29:14 -0500
In-Reply-To: <1360279864-8732-1-git-send-email-j.de.gram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/07/2013 03:31 PM, Joerie de Gram wrote:
> The BCM57766 (as found in recent Apple mac mini models) appears to be
> supported by the driver, but lacks an entry in the PCI device table.
>

Hi Joerie,
There is some additional code that needs to go in along with the 57766 device ID.
We have a combined patchset that we will be posting shortly.

Thanks,
Nithin.


> Signed-off-by: Joerie de Gram <j.de.gram@gmail.com>
> ---
>   drivers/net/ethernet/broadcom/tg3.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index bdb0869..214b27e 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -323,6 +323,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
>   	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57785)},
>   	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57761)},
>   	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57765)},
> +	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57766)},
>   	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57791),
>   	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
>   	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795),
>
