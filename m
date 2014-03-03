From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel:multicast process cause panic due to
 skb->_skb_refdst NULL pointer
Date: Mon, 03 Mar 2014 15:57:14 -0500 (EST)
Message-ID: <20140303.155714.31819771983768134.davem@davemloft.net>
References: <1393849116-3940-1-git-send-email-lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55014 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754096AbaCCU5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:57:16 -0500
In-Reply-To: <1393849116-3940-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Mon,  3 Mar 2014 20:18:36 +0800

> when ip_tunnel process multicast packets, it may check if the packet is looped
> back packet though 'rt_is_output_route(skb_rtable(skb))' in ip_tunnel_rcv(),
> but before that , skb->_skb_refdst has been dropped in iptunnel_pull_header(),
> so which leads to a panic.
> 
> fix the bug: https://bugzilla.kernel.org/show_bug.cgi?id=70681
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thank you.
