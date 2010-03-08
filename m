From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] ipg: Remove device claimed by dl2k from pci id
 table
Date: Mon, 08 Mar 2010 12:52:28 -0800 (PST)
Message-ID: <20100308.125228.122088039.davem@davemloft.net>
References: <4B956283.3000007@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org
To: jeffm@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51374
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755288Ab0CHUwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:52:09 -0500
In-Reply-To: <4B956283.3000007@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Mahoney <jeffm@suse.com>
Date: Mon, 08 Mar 2010 15:48:03 -0500

> @@ -88,7 +88,6 @@ static const char *ipg_brand_name[] = {
>  	"Sundance Technology ST2021 based NIC",
>  	"Tamarack Microelectronics TC9020/9021 based NIC",
>  	"Tamarack Microelectronics TC9020/9021 based NIC",
> - -	"D-Link NIC",
>  	"D-Link NIC IP1000A"
>  };
>  @@ -97,8 +96,7 @@ static struct pci_device_id ipg_pci_tbl[
>  	{ PCI_VDEVICE(SUNDANCE,	0x2021), 1 },
>  	{ PCI_VDEVICE(SUNDANCE,	0x1021), 2 },
>  	{ PCI_VDEVICE(DLINK,	0x9021), 3 },
> - -	{ PCI_VDEVICE(DLINK,	0x4000), 4 },
> - -	{ PCI_VDEVICE(DLINK,	0x4020), 5 },
> +	{ PCI_VDEVICE(DLINK,	0x4020), 4 },

Your patch is severely corrupted.  Please fix this up and
resubmit.
