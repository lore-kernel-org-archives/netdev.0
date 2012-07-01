From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 07/10] net/mlx4_core: Add resource tracking
 for device managed flow steering rules
Date: Sun, 01 Jul 2012 03:22:14 -0700 (PDT)
Message-ID: <20120701.032214.1975215412405340728.davem@davemloft.net>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	<1341135823-29039-8-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755242Ab2GAKWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 06:22:15 -0400
In-Reply-To: <1341135823-29039-8-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  1 Jul 2012 12:43:40 +0300

> +					err = mlx4_cmd(dev, base, 0, 0,
> +						MLX4_QP_FLOW_STEERING_DETACH,
> +						MLX4_CMD_TIME_CLASS_A,
> +						MLX4_CMD_NATIVE);

This is improperly formatted, line up the arguments with the first column
after the openning parenthesis on the first line.
