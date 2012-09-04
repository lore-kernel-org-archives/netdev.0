From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 47021] New: kernel panic with l2tpv3 & mtu > 1500
Date: Tue, 04 Sep 2012 15:55:44 -0400 (EDT)
Message-ID: <20120904.155544.1264908443145955454.davem@davemloft.net>
References: <20120904090756.71b34feb@nehalam.linuxnetplumber.net>
	<1346788334.13121.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, a1bert@atlas.cz
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932423Ab2IDTzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 15:55:47 -0400
In-Reply-To: <1346788334.13121.82.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Sep 2012 21:52:14 +0200

> [PATCH] l2tp: fix a typo in l2tp_eth_dev_recv()
> 
> While investigating l2tp bug, I hit a bug in eth_type_trans(),
> because not enough bytes were pulled in skb head.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

LoL, applied and queued up for -stable.
