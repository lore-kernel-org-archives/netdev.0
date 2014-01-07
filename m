From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 07 Jan 2014 16:19:58 -0500 (EST)
Message-ID: <20140107.161958.2246599406178837029.davem@davemloft.net>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	<1389108594-665-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, yanb@mellanox.com, shlomop@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbaAGVUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:20:00 -0500
In-Reply-To: <1389108594-665-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue,  7 Jan 2014 17:29:52 +0200

> +#define MAX_UDP_PORT (1 << 16)
> +extern const struct net_offload __rcu *udp_offloads[MAX_UDP_PORT];

Bloating the kernel up by half a megabyte just for this feature is
beyond unacceptable.
