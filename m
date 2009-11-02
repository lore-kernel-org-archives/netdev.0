From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] packet: less dev_put() calls
Date: Mon, 02 Nov 2009 03:42:57 -0800 (PST)
Message-ID: <20091102.034257.226927042.davem@davemloft.net>
References: <4AEEA9C4.6040305@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39615
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754324AbZKBLmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 06:42:33 -0500
In-Reply-To: <4AEEA9C4.6040305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2009 10:43:32 +0100

> - packet_sendmsg_spkt() can use dev_get_by_name_rcu() to avoid touching device refcount.
> 
> - packet_getname_spkt() & packet_getname() can use dev_get_by_index_rcu() to
>   avoid touching device refcount too.
> 
> tpacket_snd() & packet_snd() can not use RCU yet because they can sleep when
> allocating skb.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

You're unstoppable :-)

Applied.
