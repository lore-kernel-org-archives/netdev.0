From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: speedup netdev_set_master()
Date: Sun, 21 Mar 2010 18:37:34 -0700 (PDT)
Message-ID: <20100321.183734.149821291.davem@davemloft.net>
References: <1268955460.2894.207.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753778Ab0CVBhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:37:12 -0400
In-Reply-To: <1268955460.2894.207.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Mar 2010 00:37:40 +0100

> We currently force a synchronize_net() in netdev_set_master()
> 
> This seems necessary only when a slave had a master and we dismantle it.
> 
> In the other case ("ifenslave bond0 ethO"), we dont need this long
> delay.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
