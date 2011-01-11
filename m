From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: factorize qdisc stats handling
Date: Mon, 10 Jan 2011 16:08:15 -0800 (PST)
Message-ID: <20110110.160815.148553725.davem@davemloft.net>
References: <1294478789.2709.79.camel@edumazet-laptop>
	<20110109095735.5241e755@nehalam>
	<1294597854.2709.850.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jarkao2@gmail.com, xiaosuo@gmail.com,
	fabio@gandalf.sssup.it, netdev@vger.kernel.org, rizzo@iet.unipi.it
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752642Ab1AKAHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 19:07:46 -0500
In-Reply-To: <1294597854.2709.850.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 Jan 2011 19:30:54 +0100

> [PATCH v2] net_sched: factorize qdisc stats handling
> 
> HTB takes into account skb is segmented in stats updates.
> Generalize this to all schedulers.
> 
> They should use qdisc_bstats_update() helper instead of manipulating
> bstats.bytes and bstats.packets
> 
> Add bstats_update() helper too for classes that use
> gnet_stats_basic_packed fields.
> 
> Note : Right now, TCQ_F_CAN_BYPASS shortcurt can be taken only if no
> stab is setup on qdisc.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> v2: constify some methods, and make sure qdisc_skb_cb(skb)->pkt_len is
> set in the TCQ_F_CAN_BYPASS shortcut in __dev_xmit_skb()

Applied, thanks Eric.
