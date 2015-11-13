From: David Miller <davem@davemloft.net>
Subject: Re: via-velocity skb_over_panic
Date: Fri, 13 Nov 2015 16:07:09 -0500 (EST)
Message-ID: <20151113.160709.1777821915455809515.davem@davemloft.net>
References: <20151113184947.09d57da5@vostro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbbKMVHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 16:07:12 -0500
In-Reply-To: <20151113184947.09d57da5@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Fri, 13 Nov 2015 18:49:47 +0200

> +	if (pkt_len < 4 || pkt_len > vptr->rx.buf_sz) {
> +		VELOCITY_PRT(MSG_LEVEL_VERBOSE, KERN_ERR " %s : the received frame size %d is inconsistent.\n", vptr->netdev->name, pkt_len);
 ...
> This seems to have fixed the panics. And I do see one of the NIC's
> ethtool report's in_range_length_errors increasing once in a while. For
> some reason I don't see the above debug message though, so I'm not sure
> on what pkt_len triggers it.

You have to set the driver message level >= MSG_LEVEL_VERBOSE (3) to
see it.
