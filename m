From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] net/bonding: Enforce active-backup policy for
 IPoIB bonds
Date: Mon, 25 Jul 2016 10:19:42 -0700 (PDT)
Message-ID: <20160725.101942.47601532699202248.davem@davemloft.net>
References: <1469091175-17143-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, ogerlitz@mellanox.com,
	jiri@mellanox.com, dledford@redhat.com, markb@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbcGYRTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 13:19:45 -0400
In-Reply-To: <1469091175-17143-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 21 Jul 2016 11:52:55 +0300

> From: Mark Bloch <markb@mellanox.com>
> 
> When using an IPoIB bond currently only active-backup mode is a valid
> use case and this commit strengthens it.
> 
> Since commit 2ab82852a270 ("net/bonding: Enable bonding to enslave
> netdevices not supporting set_mac_address()") was introduced till
> 4.7-rc1, IPoIB didn't support the set_mac_address ndo, and hence the
> fail over mac policy always applied to IPoIB bonds.
> 
> With the introduction of commit 492a7e67ff83 ("IB/IPoIB: Allow setting
> the device address"), that doesn't hold and practically IPoIB bonds are
> broken as of that. To fix it, lets go to fail over mac if the device
> doesn't support the ndo OR this is IPoIB device.
> 
> As a by-product, this commit also prevents a stack corruption which
> occurred when trying to copy 20 bytes (IPoIB) device address
> to a sockaddr struct that has only 16 bytes of storage.
> 
> Signed-off-by: Mark Bloch <markb@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Applied and queued up for -stable.
