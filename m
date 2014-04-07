From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net/mlx4_core: match pci_device_id including
 dynids
Date: Mon, 07 Apr 2014 14:43:40 -0400 (EDT)
Message-ID: <20140407.144340.688537373203786487.davem@davemloft.net>
References: <1396750050-7183-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.com, ogerlitz@mellanox.com, amirv@mellanox.com,
	bhelgaas@google.com, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755577AbaDGSnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 14:43:41 -0400
In-Reply-To: <1396750050-7183-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Sun,  6 Apr 2014 10:07:30 +0800

> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
> pci_device_id.driver_data to __mlx4_init_one during reset".
> 
> pci_match_id() just match the static pci_device_id, which may return NULL if
> someone binds the driver to a device manually using
> /sys/bus/pci/drivers/.../new_id.
> 
> This patch wrap up a helper function __mlx4_remove_one() which does the tear
> down function but preserve the drv_data. Functions like
> mlx4_pci_err_detected() and mlx4_restart_one() will call this one with out
> releasing drvdata.
> 
> Tested on ConnectX-3.
> 
> CC: Bjorn Helgaas <bhelgaas@google.com>
> CC: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

Please resubmit this when the net-next tree opens back up, thanks.
