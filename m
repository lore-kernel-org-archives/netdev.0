From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 8021q: make vlan_pcpu_stats visible without
 CONFIG_VLAN_8021Q
Date: Sun, 05 Jan 2014 20:28:30 -0500 (EST)
Message-ID: <20140105.202830.2035782348969124105.davem@davemloft.net>
References: <20140106004120.GA32217@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roy.qing.li@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaAFB2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 20:28:31 -0500
In-Reply-To: <20140106004120.GA32217@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 6 Jan 2014 01:41:20 +0100

> macvlan needs vlan_pcpu_stats so make it visible even if compiling
> without VLAN_8021Q support. Otherwise a very long compiler error happens.
> 
> Fixes: cdf3e274cf1b36 ("macvlan: unify macvlan_pcpu_stats and vlan_pcpu_stats")
> Cc: Li RongQing <roy.qing.li@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thank you.
