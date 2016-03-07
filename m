From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/1] be2net: Don't leak iomapped memory on removal.
Date: Mon, 07 Mar 2016 15:38:50 -0500 (EST)
Message-ID: <20160307.153850.1268417717786820672.davem@davemloft.net>
References: <1457127416-21144-1-git-send-email-dougmill@linux.vnet.ibm.com>
	<1457127416-21144-2-git-send-email-dougmill@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
	ajit.khaparde@broadcom.com, padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: dougmill@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54010 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663AbcCGUiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:38:52 -0500
In-Reply-To: <1457127416-21144-2-git-send-email-dougmill@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Date: Fri,  4 Mar 2016 15:36:56 -0600

> The adapter->pcicfg resource is either mapped via pci_iomap() or
> derived from adapter->db. During be_remove() this resource was ignored
> and so could remain mapped after remove.
> 
> Add a flag to track whether adapter->pcicfg was mapped or not, then
> use that flag in be_unmap_pci_bars() to unmap if required.
> 
> Fixes: 25848c901 ("use PCI MMIO read instead of config read for errors")
> 
> Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>

Applied.
