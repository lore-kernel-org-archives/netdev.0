From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] don't compare skb->network_header with
 skb->tail
Date: Sun, 10 Mar 2013 16:52:28 -0400 (EDT)
Message-ID: <20130310.165228.391887733059465336.davem@davemloft.net>
References: <1362904927-44673-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	zhiguo.hong@emc.com
To: honkiko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331Ab3CJUwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 16:52:20 -0400
In-Reply-To: <1362904927-44673-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <honkiko@gmail.com>
Date: Sun, 10 Mar 2013 16:42:07 +0800

> in the case of NET_SKBUFF_DATA_USES_OFFSET(on 64-bit arch),
> skb->network_header is just offset over skb->head.
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

So is skb->tail, so there is no problem.
