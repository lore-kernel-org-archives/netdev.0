From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] NetXen: Fix NetXen driver initialization on system-P
Date: Wed, 2 May 2007 16:27:11 +0100
Message-ID: <20070502152711.GA28987@infradead.org>
References: <Pine.LNX.4.64.0705020813110.3154@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev mailing list <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>, netxenproj@linsyssoft.com,
	rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:57909 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993359AbXEBP12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 11:27:28 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705020813110.3154@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +#ifndef CONFIG_PPC
>  	if (pdev->class != 0x020000) {
>  		printk(KERN_ERR"NetXen function %d, class %x will not"
>  				"be enabled.\n",pci_func_id, pdev->class);
>  		return -ENODEV;
>  	}
> +#endif

This looks rather wrong.   Why would you require everyone to have
the class set to PCI_CLASS_NETWORK_ETHERNET, just not powerpc based
systems?

