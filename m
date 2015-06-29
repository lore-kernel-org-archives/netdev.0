From: Thomas Hellstrom <thellstrom@vmware.com>
Subject: Re: [Pv-drivers] [net-next]vmxnet3: Bump up driver version number
Date: Mon, 29 Jun 2015 19:35:33 +0200
Message-ID: <559181E5.603@vmware.com>
References: <alpine.DEB.2.02.1506290411550.12845@promg-1n-a-dhcp378.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <pv-drivers@vmware.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:60758 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752298AbbF2RgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 13:36:14 -0400
Received: from sc9-mailhost1.vmware.com (sc9-mailhost1.vmware.com [10.113.161.71])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id B6D3C28490
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 10:36:13 -0700 (PDT)
Received: from EX13-CAS-011.vmware.com (EX13-CAS-011.vmware.com [10.113.191.63])
	by sc9-mailhost1.vmware.com (Postfix) with ESMTP id 532F7181D8
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 10:36:13 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1506290411550.12845@promg-1n-a-dhcp378.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2015 01:14 PM, Shreyas Bhatewara wrote:
> Bump up the driver version number to reflect the changes done to
> work with vmxnet3 adapter version 2
>
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>

> ---
>
> diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
> index e9f1075..2652245 100644
> --- a/drivers/net/vmxnet3/vmxnet3_int.h
> +++ b/drivers/net/vmxnet3/vmxnet3_int.h
> @@ -69,10 +69,10 @@
>  /*
>   * Version numbers
>   */
> -#define VMXNET3_DRIVER_VERSION_STRING   "1.3.5.0-k"
> +#define VMXNET3_DRIVER_VERSION_STRING   "1.4.2.0-k"
>  
>  /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
> -#define VMXNET3_DRIVER_VERSION_NUM      0x01030500
> +#define VMXNET3_DRIVER_VERSION_NUM      0x01040200
>  
>  #if defined(CONFIG_PCI_MSI)
>  	/* RSS only makes sense if MSI-X is supported. */
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
