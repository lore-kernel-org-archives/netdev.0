From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] mlx4: Add support for single port VFs
Date: Thu, 20 Mar 2014 16:20:11 -0400 (EDT)
Message-ID: <20140320.162011.105658048451341992.davem@davemloft.net>
References: <1395245513-8139-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com, matanb@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758075AbaCTUUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:20:14 -0400
In-Reply-To: <1395245513-8139-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 19 Mar 2014 18:11:48 +0200

> The mlx4 Firmware && driver expose both ports of the device through one PCI function.
> 
> This can be non-optimal under virtualization schemes where the admin 
> would like the VF to expose one interface to the VM, etc.
> 
> This series from Matan Barak adds support for single ported VFs. 
> 
> Since all the VF interaction with the firmware passes through the PF
>  driver, we can emulate to the VF they have one port, and further create 
> a set of the VFs which act on port1 of the device and another set which 
> acts on port2.
> 
> Series done against net-next commit 3ab428a "netfilter: Add missing 
> vmalloc.h include to nft_hash.c"
> 
> Roland, we send this through netdev, but if you have comments, will love
> to hear them.

Series applied, thanks.
