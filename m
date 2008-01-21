From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] dsmark: handle cloned and non-linear skb's
Date: Mon, 21 Jan 2008 02:23:59 -0800 (PST)
Message-ID: <20080121.022359.201369181.davem@davemloft.net>
References: <20080120131008.2039a35d@deepthought>
	<20080120132354.55de46ed@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765948AbYAUKXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 05:23:54 -0500
In-Reply-To: <20080120132354.55de46ed@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 20 Jan 2008 13:23:54 -0800

> Make dsmark work properly with non-linear and cloned skb's
> Before modifying the header, it needs to check that skb header is
> writeable.
> 
> Note: this makes the assumption, that if it queues a good skb
> then a good skb will come out of the embedded qdisc.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
