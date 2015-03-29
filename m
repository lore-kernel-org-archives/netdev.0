From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_syn_flood_action() can be static
Date: Sun, 29 Mar 2015 12:17:51 -0700 (PDT)
Message-ID: <20150329.121751.1338570789876137198.davem@davemloft.net>
References: <1427321327.25985.124.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, octavian.purdila@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbbC2TJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:09:06 -0400
In-Reply-To: <1427321327.25985.124.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Mar 2015 15:08:47 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 1fb6f159fd21 ("tcp: add tcp_conn_request"),
> tcp_syn_flood_action() is no longer used from IPv6.
> 
> We can make it static, by moving it above tcp_conn_request()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to net-next, thanks.
