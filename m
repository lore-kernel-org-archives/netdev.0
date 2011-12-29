From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] mlx4_core: limiting VF port options
Date: Thu, 29 Dec 2011 15:09:59 -0500 (EST)
Message-ID: <20111229.150959.49185424410920094.davem@davemloft.net>
References: <4EFCA68F.9060904@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018Ab1L2UKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 15:10:05 -0500
In-Reply-To: <4EFCA68F.9060904@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 29 Dec 2011 19:42:39 +0200

> 
> At the moment VFs can only operate in Eth mode.
> In addition we don't want the VF to attempt link sensing,
> so we block this option as well.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied, but:

> +#define MLX4_VF_PORT_ETH_ONLY_MASK	0xE6

Why don't you just clearly define what all the port type bits mean
instead of only defining some arbitrary combination of them?

What if people want to experiment with other bit mask settings?  They
can't do that if you don't document the layout fully and properly.
