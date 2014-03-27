From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: pass pci_device_id.driver_data to
 __mlx4_init_one during reset
Date: Thu, 27 Mar 2014 15:36:12 -0400 (EDT)
Message-ID: <20140327.153612.643354861874841336.davem@davemloft.net>
References: <1395883711-23607-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jackm@dev.mellanox.co.il, ogerlitz@mellanox.com,
	netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902AbaC0TgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 15:36:14 -0400
In-Reply-To: <1395883711-23607-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Thu, 27 Mar 2014 09:28:31 +0800

> The second parameter of __mlx4_init_one() is used to identify whether the
> pci_dev is a PF or VF. Currently, when it is invoked in mlx4_pci_slot_reset()
> this information is missed.
> 
> This patch match the pci_dev with mlx4_pci_table and passes the
> pci_device_id.driver_data to __mlx4_init_one() in mlx4_pci_slot_reset().
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

Applied, thanks.
