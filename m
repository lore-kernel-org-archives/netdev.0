From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] net: add killer e2400 device id
Date: Tue, 24 Nov 2015 15:49:14 +0300
Message-ID: <56545CCA.9000606@cogentembedded.com>
References: <BN3PR0401MB14572E9C2572B4C1FFFF881DC0060@BN3PR0401MB1457.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Owen Lin <olin@rivetnetworks.com>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35305 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbbKXMtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 07:49:17 -0500
Received: by lfdl133 with SMTP id l133so18938518lfd.2
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 04:49:16 -0800 (PST)
In-Reply-To: <BN3PR0401MB14572E9C2572B4C1FFFF881DC0060@BN3PR0401MB1457.namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/24/2015 4:18 AM, Owen Lin wrote:

> Add Killer E2400 device ID in alx driver.
>
> Signed-off-by: Owen Lin olin@rivetnetworks.com
>
> --------------------------------------------------------------------------------
> diff -uprN alx_orig/main.c alx/main.c

    The patch should be applicable with the -p1 option.

> --- alx_orig/main.c	Mon Sep  7 13:00:58 2015
> +++ alx/main.c	Mon Sep  7 14:47:03 2015
> @@ -1537,6 +1537,7 @@ static const struct pci_device_id alx_pc
>   	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8162),
>   	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
>   	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8171) },
> +	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2400) },
>   	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8172) },
>   	{}
>   };
> diff -uprN alx_orig/reg.h alx/reg.h
> --- alx_orig/reg.h	Mon Sep  7 13:00:58 2015
> +++ alx/reg.h	Mon Sep  7 14:46:16 2015
> @@ -39,6 +39,7 @@
>   #define ALX_DEV_ID_E2200				0xe091
>   #define ALX_DEV_ID_AR8162				0x1090
>   #define ALX_DEV_ID_AR8171				0x10A1
> +#define ALX_DEV_ID_E2400				0xe0A1

    Either all upper case (which seem to follow what the other IDs have) or 
all lower case.

>   #define ALX_DEV_ID_AR8172				0x10A0
>
>   /* rev definition,

MBR, Sergei
