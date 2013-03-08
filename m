From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridging: fix rx_handlers return code
Date: Fri, 08 Mar 2013 12:20:36 -0500 (EST)
Message-ID: <20130308.122036.2263030198692462238.davem@davemloft.net>
References: <1362762218-5198-1-git-send-email-B43982@freescale.com>
	<1362762850.15793.245.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B43982@freescale.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964813Ab3CHRUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:20:38 -0500
In-Reply-To: <1362762850.15793.245.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Mar 2013 09:14:10 -0800

> On Fri, 2013-03-08 at 19:03 +0200, Cristian Bercaru wrote:
>> The frames for which rx_handlers return RX_HANDLER_CONSUMED are no longer
>> counted as dropped. They are counted as successfully received by
>> 'netif_receive_skb'.
>> 
>> This allows network interface drivers to correctly update their RX-OK and
>> RX-DRP counters based on the result of 'netif_receive_skb'.
>> 
>> Signed-off-by: Cristian Bercaru <B43982@freescale.com>
>> ---
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
