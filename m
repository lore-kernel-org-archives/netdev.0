From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Mon, 14 Nov 2011 00:08:11 -0500 (EST)
Message-ID: <20111114.000811.780218767629149648.davem@davemloft.net>
References: <1321213338.17837.38.camel@edumazet-laptop>
	<1321214895.3101.3.camel@lb-tlvb-eilong.il.broadcom.com>
	<1321221657.17837.51.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, bhutchings@solarflare.com,
	pstaszewski@itcare.pl, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab1KNFIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 00:08:23 -0500
In-Reply-To: <1321221657.17837.51.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 13 Nov 2011 23:00:57 +0100

> OK then we need using build_skb() for this driver :)
> 
> http://lists.openwall.net/netdev/2011/07/11/19
> 
> This way, we build the skb_shared_info content _after_ frame is
> delivered by device.

I fully support bringing this thing back to life :-)
