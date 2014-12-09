From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 net-next] net: bcmgenet: bcmgenet_init_tx_ring()
 cleanup
Date: Tue, 09 Dec 2014 13:43:25 -0500 (EST)
Message-ID: <20141209.134325.414522197018623848.davem@davemloft.net>
References: <20141204041131.830CB2200C7@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaLISn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:43:27 -0500
In-Reply-To: <20141204041131.830CB2200C7@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Wed,  3 Dec 2014 20:11:31 -0800 (PST)

> -/* Initialize all house-keeping variables for a TX ring, along
> - * with corresponding hardware registers
> +/*
> + * Initialize a Tx ring along with corresponding hardware registers.
>   */

You are breaking the coding style of this comment.

In the Linux networking, the proper comment layout is:

	/* Like
	 * this.
	 */

not:

	/*
	 * Like this.
	 */

Thanks.
