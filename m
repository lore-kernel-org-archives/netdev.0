From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: use napi_complete_done()
Date: Wed, 13 Apr 2016 23:37:56 -0400 (EDT)
Message-ID: <20160413.233756.403217690817544709.davem@davemloft.net>
References: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, f.fainelli@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbcDNDh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 23:37:58 -0400
In-Reply-To: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Apr 2016 22:06:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> By using napi_complete_done(), we allow fine tuning
> of /sys/class/net/ethX/gro_flush_timeout for higher GRO aggregation
> efficiency for a Gbit NIC.
> 
> Check commit 24d2e4a50737 ("tg3: use napi_complete_done()") for details.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
