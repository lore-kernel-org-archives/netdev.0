From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/2] tcp: introduce tcp_data_queue_ofo
Date: Mon, 19 Mar 2012 16:57:45 -0400 (EDT)
Message-ID: <20120319.165745.234764335458562219.davem@davemloft.net>
References: <1332077854.3722.52.camel@edumazet-laptop>
	<CADVnQy=_Adr9xTd=7aUFT6m38YQ8V-V7KQc9c6L4nej-dfvekQ@mail.gmail.com>
	<1332104804.3597.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, therbert@google.com,
	ilpo.jarvinen@helsinki.fi, hkchu@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753682Ab2CSU6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 16:58:01 -0400
In-Reply-To: <1332104804.3597.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 18 Mar 2012 14:06:44 -0700

> Split tcp_data_queue() in two parts for better readability.
> 
> tcp_data_queue_ofo() is responsible for queueing incoming skb into out
> of order queue.
> 
> Change code layout so that the skb_set_owner_r() is performed only if
> skb is not dropped.
> 
> This is a preliminary patch before "reduce out_of_order memory use"
> following patch.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
