From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 01/11] ixgb: Fix compilation errors by initializing variables
Date: Sat, 22 Apr 2006 10:49:45 +0200
Message-ID: <20060422084945.GA26666@electric-eye.fr.zoreil.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com> <20060422010031.24255.54593.stgit@jk-desktop.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:45973 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1750785AbWDVRSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2006 13:18:54 -0400
Received: from fr.zoreil.com (electric-eye.fr.zoreil.com [213.41.134.224])
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k3M8tpIL023881
	for <netdev@vger.kernel.org>; Sat, 22 Apr 2006 08:55:53 GMT
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Content-Disposition: inline
In-Reply-To: <20060422010031.24255.54593.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
> index cfd67d8..0b9481a 100644
> --- a/drivers/net/ixgb/ixgb_main.c
> +++ b/drivers/net/ixgb/ixgb_main.c
[...]
> @@ -346,7 +346,7 @@ ixgb_probe(struct pci_dev *pdev,
>  		const struct pci_device_id *ent)
>  {
>  	struct net_device *netdev = NULL;
> -	struct ixgb_adapter *adapter;
> +	struct ixgb_adapter *adapter = NULL;

Afaiks the warning/error from the compiler is bogus.

netdev initialization is useless as well.

Are we supposed to bloat the kernel code on a large scale just
to please a compiler which emits bogus warning or is the option
left to the maintainer ?


-- 
Ueimor
