From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4: TCP/UDP packets have L4 hash
Date: Wed, 08 Jul 2015 13:45:35 -0700 (PDT)
Message-ID: <20150708.134535.2114532891527883817.davem@davemloft.net>
References: <1435836284.11970.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, idos@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbbGHUpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 16:45:36 -0400
In-Reply-To: <1435836284.11970.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Jul 2015 13:24:44 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Mellanox driver has the knowledge if rxhash is a L4 hash,
> if it receives a non fragmented TCP or UDP frame and
> NETIF_F_RXCSUM is enabled on netdev.
> 
> ip_summed value is CHECKSUM_UNNECESSARY in this case.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to net-next, thanks.
