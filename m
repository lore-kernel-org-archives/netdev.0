From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 04/10] net/mlx4: Set steering mode according
 to device capabilities
Date: Sun, 01 Jul 2012 03:20:21 -0700 (PDT)
Message-ID: <20120701.032021.1411105632982008574.davem@davemloft.net>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	<1341135823-29039-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755561Ab2GAKUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 06:20:22 -0400
In-Reply-To: <1341135823-29039-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  1 Jul 2012 12:43:37 +0300

> +				/* Add the default qp number as multicast
> +				* promisc */

This is not the correct way to format a comment, do it:

	/* Like
	 * this.
	 */

> +	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER &&
> +	    dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER) {
> +		dev->caps.steering_mode = MLX4_STEERING_MODE_B0;
> +
> +	} else {

That empty line is extraneous and ugly, remove it.

> +/* Driver supports 2 diffrent device methods to manage traffic steering:
> +	- B0 steering mode - Common low level API for ib and (if supported) eth.
> +	- A0 steering mode - Limited low level API for eth. In case of IB,
> +			     B0 mode is in use.
> + */

Improperly formatted, do it like this:

/* Driver supports 2 diffrent device methods to manage traffic steering:
 *	- B0 steering mode - Common low level API for ib and (if supported) eth.
 *	- A0 steering mode - Limited low level API for eth. In case of IB,
 *			     B0 mode is in use.
 */
