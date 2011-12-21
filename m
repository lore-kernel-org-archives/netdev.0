From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netlink: af_netlink cleanup
Date: Wed, 21 Dec 2011 18:01:36 -0500 (EST)
Message-ID: <20111221.180136.610469424748656825.davem@davemloft.net>
References: <20111221134729.3d652e24@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072Ab1LUXBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 18:01:38 -0500
In-Reply-To: <20111221134729.3d652e24@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 21 Dec 2011 13:47:29 -0800

> -static inline struct sk_buff *netlink_trim(struct sk_buff *skb,
> +static struct sk_buff *netlink_trim(struct sk_buff *skb,
>  					   gfp_t allocation)

Please fix up the subsequent lines so that the arguments still line
up properly with the preceeding line's openning parens.
