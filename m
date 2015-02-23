From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pktgen: disable xmit_clone on virtual devices
Date: Sun, 22 Feb 2015 22:43:56 -0500 (EST)
Message-ID: <20150222.224356.174314995301974558.davem@davemloft.net>
References: <1424653421.5565.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbbBWDoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 22:44:13 -0500
In-Reply-To: <1424653421.5565.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 22 Feb 2015 17:03:41 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Trying to use burst capability (aka xmit_more) on a virtual device
> like bonding is not supported.
> 
> For example, skb might be queued multiple times on a qdisc, with
> various list corruptions.
> 
> Fixes: 38b2cf2982dc ("net: pktgen: packet bursting via skb->xmit_more")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
