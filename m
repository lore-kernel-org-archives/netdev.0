From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 27 Jan 2014 13:08:19 -0800 (PST)
Message-ID: <20140127.130819.301043802179596479.davem@davemloft.net>
References: <1390810971-23959-2-git-send-email-fw@strlen.de>
	<1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140127.125838.2234405619673167551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbaA0VIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 16:08:20 -0500
In-Reply-To: <20140127.125838.2234405619673167551.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 27 Jan 2014 12:58:38 -0800 (PST)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 27 Jan 2014 10:22:47 -0800
> 
>> Its still unclear if this is the best strategy.
>> 
>> TCP stream not using DF flag are very unlikely to care if we adjust
>> their MTU (lowering gso_size) at this point ?
> 
> It's better than what happens now when the destination link has a lower
> MTU, wouldn't you say?

In the mean time I'll hold off on this patch while you guys discuss
this.
