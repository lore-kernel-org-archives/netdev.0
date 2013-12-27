From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: release dst properly in ipip6_tunnel_xmit
Date: Fri, 27 Dec 2013 13:16:17 -0500 (EST)
Message-ID: <20131227.131617.242486361462334879.davem@davemloft.net>
References: <1387531212-17034-1-git-send-email-roy.qing.li@gmail.com>
	<1387549006.19078.428.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127Ab3L0SQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 13:16:19 -0500
In-Reply-To: <1387549006.19078.428.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Dec 2013 06:16:46 -0800

> On Fri, 2013-12-20 at 17:20 +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>> 
>> if a dst is not attached to anywhere, it should be released before
>> exit ipip6_tunnel_xmit, otherwise cause dst memory leakage.
>> 
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
...
> Fixes: 61c1db7fae21 ("ipv6: sit: add GSO/TSO support")
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
