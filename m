From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Sun, 13 Apr 2014 23:14:03 -0400 (EDT)
Message-ID: <20140413.231403.935690370456036216.davem@davemloft.net>
References: <1397440279-6004-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, bhelgaas@google.com,
	amirv@mellanox.com, jackm@dev.mellanox.co.il, ogerlitz@mellanox.com
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaDNDOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2014 23:14:06 -0400
In-Reply-To: <1397440279-6004-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Mon, 14 Apr 2014 09:51:19 +0800

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
> Acked-by: Jack Morgenstein <jackm@dev.mellanox.co.il>

Applied and queued up for -stable, thanks.
