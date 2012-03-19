From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Mon, 19 Mar 2012 17:21:55 -0400 (EDT)
Message-ID: <20120319.172155.1599328940188499704.davem@davemloft.net>
References: <1331888235-10368-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20120319080220.GA29891@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028Ab2CSVWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 17:22:11 -0400
In-Reply-To: <20120319080220.GA29891@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 19 Mar 2012 09:02:20 +0100

> On Fri, Mar 16, 2012 at 04:57:15PM +0800, Gao feng wrote:
>> Call skb_pull reduce skb->len before next "while cycle"
> 
> I think it would be better to just reserve headroom for
> dst_exthdrlen instead of adding and removing data to/from
> the skb.

Agreed, that would be a lot nicer.
