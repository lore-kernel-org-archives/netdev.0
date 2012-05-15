From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 1/8] net/mlx4: Address build warnings on
 set but not used variables
Date: Tue, 15 May 2012 13:38:08 -0400 (EDT)
Message-ID: <20120515.133808.1788429614608005541.davem@davemloft.net>
References: <1337066690-2248-1-git-send-email-ogerlitz@mellanox.com>
	<1337066690-2248-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, yevgenyp@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965421Ab2EORiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 13:38:17 -0400
In-Reply-To: <1337066690-2248-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 15 May 2012 10:24:43 +0300

> -		err = mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
> -				   RES_OP_RESERVE_AND_MAP, MLX4_CMD_FREE_RES,
> -				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
> +		(void) mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
> +					RES_OP_RESERVE_AND_MAP, MLX4_CMD_FREE_RES,
> +					MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);

Please stop wasting my time.  This is not the correct way to indent
functions that have arguments on multiple lines.

I'll say it one more time:

	The first character must line up with the column right after
	the openning parenthesis on the first line.

This means you DO NOT use only TAB characters and indent the thing
into the solar system like you have above.

Instead you use TAB and SPACE characters, as needed, to line it up
properly, like so:

	func(arg1, arg2,
	     arg3, arg4);
