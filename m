From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: RTA_MARK addition
Date: Thu, 22 Jul 2010 13:46:32 -0700 (PDT)
Message-ID: <20100722.134632.15715628.davem@davemloft.net>
References: <1279699394.2452.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48328
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759992Ab0GVUqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 16:46:15 -0400
In-Reply-To: <1279699394.2452.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Jul 2010 10:03:14 +0200

> Add a new rt attribute, RTA_MARK, and use it in
> rt_fill_info()/inet_rtm_getroute() to support following commands :
> 
> ip route get 192.168.20.110 mark NUMBER
> ip route get 192.168.20.108 from 192.168.20.110 iif eth1 mark NUMBER
> ip route list cache [192.168.20.110] mark NUMBER
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
