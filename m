From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] netxen: add pci ids
Date: Sat, 13 Sep 2008 15:30:32 -0400
Message-ID: <48CC14D8.5090900@garzik.org>
References: <> <1221227714-8382-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50155 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695AbYIMTaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:30:35 -0400
In-Reply-To: <1221227714-8382-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke wrote:
> Define old and new pci vendor and device ids.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic_main.c |   18 +++++++++---------
>  include/linux/pci_ids.h              |   10 ++++++++++
>  2 files changed, 19 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index 008fd66..0f8ea2c 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -77,18 +77,18 @@ static irqreturn_t netxen_msi_intr(int irq, void *data);
>  
>  /*  PCI Device ID Table  */
>  #define ENTRY(device) \
> -	{PCI_DEVICE(0x4040, (device)), \
> +	{PCI_DEVICE(PCI_VENDOR_ID_NETXEN, (device)), \
>  	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
>  
>  static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
> -	ENTRY(0x0001),
> -	ENTRY(0x0002),
> -	ENTRY(0x0003),
> -	ENTRY(0x0004),
> -	ENTRY(0x0005),
> -	ENTRY(0x0024),
> -	ENTRY(0x0025),
> -	ENTRY(0x0100),
> +	ENTRY(PCI_DEVICE_ID_NX2031_10GXSR),
> +	ENTRY(PCI_DEVICE_ID_NX2031_10GCX4),
> +	ENTRY(PCI_DEVICE_ID_NX2031_4GCU),
> +	ENTRY(PCI_DEVICE_ID_NX2031_IMEZ),
> +	ENTRY(PCI_DEVICE_ID_NX2031_HMEZ),
> +	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT),
> +	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT2),
> +	ENTRY(PCI_DEVICE_ID_NX3031),
>  	{0,}
>  };

applied


