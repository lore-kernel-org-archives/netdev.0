From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: propagate max_gso_segs and max_gso_size
Date: Mon, 21 Mar 2016 13:36:19 -0400 (EDT)
Message-ID: <20160321.133619.875632620021421615.davem@davemloft.net>
References: <1458579311-17699-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	pgynther@google.com, stephen@networkplumber.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757148AbcCURgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 13:36:21 -0400
In-Reply-To: <1458579311-17699-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 21 Mar 2016 09:55:09 -0700

> bridge code does not properly update max_gso_segs and max_gso_size.
> 
> Since this was not really obvious, first patch adds two new rtnetlink
> attributes to help debugging this kind of issues (ip -d link)
> 
> Second patch fixes bridge code.

Series applied, thanks Eric.
