From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/6] IP100A, add end of pci id table
Date: Thu, 17 Aug 2006 10:45:14 -0400
Message-ID: <44E480FA.70806@pobox.com>
References: <1155841247.4532.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965067AbWHQOpX@vger.kernel.org>
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <1155841247.4532.6.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Huang wrote:
> @@ -212,7 +212,7 @@ static const struct pci_device_id sundan
>  	{ 0x1186, 0x1002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4 },
>  	{ 0x13F0, 0x0201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5 },
>  	{ 0x13F0, 0x0200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6 },
> -	{ }
> +	{ 0,}
>  };
>  MODULE_DEVICE_TABLE(pci, sundance_pci_tbl);
>  
> @@ -231,7 +231,7 @@ static const struct pci_id_info pci_id_t
>  	{"D-Link DL10050-based FAST Ethernet Adapter"},
>  	{"Sundance Technology Alta"},
>  	{"IC Plus Corporation IP100A FAST Ethernet Adapter"},
> -	{ }	/* terminate list. */
> +	{ NULL,}	/* terminate list. */

NAK.

An empty array element "{ }" implies NULL.  It is the kernel standard to 
prefer "{ }" over an explicit initialization.  Looks cleaner.

	Jeff
