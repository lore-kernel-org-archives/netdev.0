From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Fri, 11 Apr 2014 16:26:12 -0400 (EDT)
Message-ID: <20140411.162612.1925975958141238668.davem@davemloft.net>
References: <1397121924-14813-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	bhelgaas@google.com, amirv@mellanox.com, jackm@dev.mellanox.co.il,
	ogerlitz@mellanox.com
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbaDKU0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 16:26:14 -0400
In-Reply-To: <1397121924-14813-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Thu, 10 Apr 2014 17:25:24 +0800

> pci_match_id() just match the static pci_device_id, which may return NULL if
> someone binds the driver to a device manually using
> /sys/bus/pci/drivers/.../new_id.
> 
> This patch wrap up a helper function __mlx4_remove_one() which does the tear
> down function but preserve the drv_data. Functions like
> mlx4_pci_err_detected() and mlx4_restart_one() will call this one with out
> releasing drvdata.
> 
> Fixes: 97a5221 "net/mlx4_core: pass pci_device_id.driver_data to __mlx4_init_one during reset".
> 
> CC: Bjorn Helgaas <bhelgaas@google.com>
> CC: Amir Vadai <amirv@mellanox.com>
> CC: Jack Morgenstein <jackm@dev.mellanox.co.il>
> CC: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> 
> ---
> V0 --> V1:
>    1. zero the mlx4_priv at the end of __mlx4_remove_one
>    2. add a flag in mlx4_priv to mark it is released or not

This doesn't apply to the current 'net' tree, please respin.

And Jack, please do not place any leading spaces before your "Acked-by:",
patchwork will not parse it correctly and pick it up automatically for
me if you do that.

Thanks.
