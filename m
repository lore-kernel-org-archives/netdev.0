From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_core: Respond to operation request
 by firmware
Date: Mon, 29 Jul 2013 01:12:53 -0700 (PDT)
Message-ID: <20130729.011253.1064287168678653852.davem@davemloft.net>
References: <1375026861-14215-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, jackm@dev.mellanox.com, eugenia@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab3G2IMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 04:12:54 -0400
In-Reply-To: <1375026861-14215-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun, 28 Jul 2013 18:54:21 +0300

> From: Yevgeny Petrilin <yevgenyp@mellanox.com>
> 
> This commit adds new firmware command and new firmware event.  The firmware
> raises the MLX4_EVENT_TYPE_OP_REQUIRED event in order to signal the driver it
> needs to perform an administrative operation throughout the MLX4_CMD_GET_OP_REQ
> command. At the moment the supported operation is adding/removing multicast
> entries which are used by the firmware for handling NCSI traffic in B0
> steering mode.
> 
> Also, had to swap the order of mlx4_init_mcg_table() and
> mlx4_init_eq_table() to make sure that driver will get events only after
> resources are initialized to handle it.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.com>
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
