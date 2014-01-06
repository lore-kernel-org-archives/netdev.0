From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1] net/mlx4_core: Warn if device doesn't have
 enough PCI bandwidth
Date: Sun, 05 Jan 2014 20:37:22 -0500 (EST)
Message-ID: <20140105.203722.970589305806242665.davem@davemloft.net>
References: <1388936468-5293-1-git-send-email-eyalpe@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, amirv@mellanox.com
To: eyalpe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbaAFBhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 20:37:23 -0500
In-Reply-To: <1388936468-5293-1-git-send-email-eyalpe@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>
Date: Sun,  5 Jan 2014 17:41:08 +0200

> Check if the device get enough bandwidth from the entire PCI chain to satisfy
> its capabilities. This patch determines the PCIe device's bandwidth capabilities
> by reading its PCIe Link Capabilities registers and then call the
> pcie_get_minimum_link function to ensure that the adapter is hooked into a slot
> which is capable of providing the necessary bandwidth capabilities.
> 
> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
