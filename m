From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] mlx4: Enable single ported VFs over IB
 ports
Date: Sun, 24 May 2015 23:13:28 -0400 (EDT)
Message-ID: <20150524.231328.2181794390276967632.davem@davemloft.net>
References: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, dledford@redhat.com,
	amirv@mellanox.com, talal@mellanox.com, jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbbEYDNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2015 23:13:31 -0400
In-Reply-To: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 21 May 2015 15:14:04 +0300

> This series further enhances the support for mlx4 single ported VFs 
> introduced in 3.15 to work over IB ports too. 
> 
> Just as quick reminder, the ConnectX3 device family exposes one PCI device 
> which serves both ports. 
> 
> This can be non-optimal under virtualization schemes where the admin
> would like the VF to expose one interface to the VM, etc.
> 
> Since all the VF interaction with the firmware passes through the PF
> driver, we can emulate to the VF they have one port, and further create
> a set of the VFs which act on port1 of the device and another set which
> acts on port2.

Series applied, thanks.
