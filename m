From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Allow not to specify probe_vf in
 SRIOV IB mode
Date: Fri, 26 Sep 2014 16:47:15 -0400 (EDT)
Message-ID: <20140926.164715.648150882985516578.davem@davemloft.net>
References: <1411477559-22155-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, matanb@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbaIZUrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 16:47:17 -0400
In-Reply-To: <1411477559-22155-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 23 Sep 2014 16:05:59 +0300

> From: Matan Barak <matanb@mellanox.com>
> 
> When the HCA is configured in SRIOV IB mode (that is, at least one of
> the ports is IB) and the probe_vf module param isn't specified,
> mlx4_init_one() failed because of the following condition:
> 
> if (ib_ports && (num_vfs_argc > 1 || probe_vfs_argc > 1)) {
> 	 .....
> }
> 
> The root cause for that is a mistake in the initialization of num_vfs_argc
> and probe_vfs_argc. When num_vfs / probe_vf aren't given, their argument
> count counterpart should be 0, fix that.
> 
> Fixes: dd41cc3bb90e ('net/mlx4: Adapt num_vfs/probed_vf params for single port VF')
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied.

> This bug was introduced in 3.16, can you please push this patch along 
> with commit a91c772fa0275 "net/mlx4: Correctly configure single ported 
> VFs from the host" to 3.16-stable

Both patches queued up for -stable, thanks.
