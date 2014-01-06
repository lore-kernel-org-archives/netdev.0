From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_core: Warn if device doesn't have
 enough PCI bandwidth
Date: Mon, 06 Jan 2014 16:21:20 -0500 (EST)
Message-ID: <20140106.162120.2010532785090508777.davem@davemloft.net>
References: <1388863024-8718-1-git-send-email-amirv@mellanox.com>
	<1389042955.9947.110.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, jeffrey.t.kirsher@intel.com,
	bhelgaas@google.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	eyalpe@mellanox.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755702AbaAFVVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:21:22 -0500
In-Reply-To: <1389042955.9947.110.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 6 Jan 2014 21:15:55 +0000

> We ought to have a generic PCI layer function that warns when a PCIe
> device is running below maximum link width/speed.  Maybe even run it as
> soon as the device is enumerated, so that a driver doesn't need to do
> anything.

Agreed.
