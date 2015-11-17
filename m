From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] af_unix: take receive queue lock while appending
 new skb
Date: Tue, 17 Nov 2015 15:27:13 -0500 (EST)
Message-ID: <20151117.152713.294669962025741880.davem@davemloft.net>
References: <1447769459-30452-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbbKQU1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 15:27:14 -0500
In-Reply-To: <1447769459-30452-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 17 Nov 2015 15:10:59 +0100

> While possibly in future we don't necessarily need to use
> sk_buff_head.lock this is a rather larger change, as it affects the
> af_unix fd garbage collector, diag and socket cleanups. This is too much
> for a stable patch.
> 
> For the time being grab sk_buff_head.lock without disabling bh and irqs,
> so don't use locked skb_queue_tail.
> 
> Fixes: 869e7c62486e ("net: af_unix: implement stream sendpage support")
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
