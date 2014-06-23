From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Fix the error flow when probing
 with invalid VF configuration
Date: Sun, 22 Jun 2014 17:14:20 -0700 (PDT)
Message-ID: <20140622.171420.991097188399216331.davem@davemloft.net>
References: <1403432494-20043-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, matanb@mellanox.com,
	jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbaFWAOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 20:14:21 -0400
In-Reply-To: <1403432494-20043-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 22 Jun 2014 13:21:34 +0300

> Single ported VF are currently not supported on configurations where
> one or both ports are IB. When we hit this case, the relevant flow in
> the driver didn't return error and jumped to the wrong label. Fix that.
> 
> Fixes: dd41cc3 ('net/mlx4: Adapt num_vfs/probed_vf params for single port VF')
> Reported-by: Shirley Ma <shirley.ma@oracle.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied and queued up for -stable, thanks.
