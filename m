From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: trival improvements
Date: Thu, 19 Dec 2013 14:45:50 -0500 (EST)
Message-ID: <20131219.144550.1168547541317435358.davem@davemloft.net>
References: <1387433932-2745-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755991Ab3LSTpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:45:52 -0500
In-Reply-To: <1387433932-2745-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 19 Dec 2013 14:18:52 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 1. remove the unnecessary setting rt.rt6i_metric to 0 since memset() has clear
> them.
> 2. call ip6_rt_put to release rt only when rt is not null in addrconf_prefix_rcv.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

ip6_rt_put() transparently handles NULL just fine, don't special
case it like this.
