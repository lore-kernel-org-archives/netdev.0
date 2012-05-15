From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] net/mlx4: Address build warnings on set
 but not used variables
Date: Tue, 15 May 2012 00:07:54 -0400 (EDT)
Message-ID: <20120515.000754.1011080018257342361.davem@davemloft.net>
References: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
	<1337025853-26685-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940Ab2EOEIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 00:08:02 -0400
In-Reply-To: <1337025853-26685-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Mon, 14 May 2012 23:04:06 +0300

> -		err = mlx4_qp_detach_common(dev, &qp, rgid->gid, rgid->prot,
> +		(void) mlx4_qp_detach_common(dev, &qp, rgid->gid, rgid->prot,
>  					    rgid->steer);

You must update the indentation of all the lines comprising of the function
call when you change the indentation of it's initial line.

Please go through all of your patches in this series and fix that up.
