From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 1/6] IP100A, add end of pci id table
Date: Thu, 17 Aug 2006 19:19:45 +0400
Message-ID: <20060817151945.GC5205@martell.zuzino.mipt.ru>
References: <1155841247.4532.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:4928 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S965132AbWHQPTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 11:19:54 -0400
Received: by wr-out-0506.google.com with SMTP id i21so98799wra
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2006 08:19:53 -0700 (PDT)
To: Jesse Huang <jesse@icplus.com.tw>
Content-Disposition: inline
In-Reply-To: <1155841247.4532.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2006 at 03:00:47PM -0400, Jesse Huang wrote:
> Add "0," and "NULL," to sundance_pci_tbl and pci_id_table.

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

They are already properly terminated. You don't have to do anything.

