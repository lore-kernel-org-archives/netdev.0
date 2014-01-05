From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Sat, 04 Jan 2014 20:09:31 -0500 (EST)
Message-ID: <20140104.200931.524755895829922293.davem@davemloft.net>
References: <1388813047-5262-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189AbaAEBJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 20:09:32 -0500
In-Reply-To: <1388813047-5262-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Fri,  3 Jan 2014 21:24:07 -0800

> +struct packet_offload *gro_find_receive_by_type(__be16 type);
> +struct packet_offload *gro_find_complete_by_type(__be16 type);

You're not exporting these to modules, therefore if GRE is built
modular it won't work.

Please use GPL exports.
