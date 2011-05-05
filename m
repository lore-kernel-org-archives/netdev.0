From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] net: drivers: set TSO/UFO offload option
 explicitly
Date: Thu, 05 May 2011 10:54:51 -0700 (PDT)
Message-ID: <20110505.105451.39198990.davem@davemloft.net>
References: <4DBA4DF5.5020101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, mst@redhat.com,
	eric.dumazet@gmail.com, mirq-linux@rere.qmqm.pl, mirqus@gmail.com,
	bhutchings@solarflare.com, dm@chelsio.com
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45542
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754435Ab1EERzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 13:55:24 -0400
In-Reply-To: <4DBA4DF5.5020101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 29 Apr 2011 13:34:45 +0800

> The device drivers should not use NETIF_F_ALL_TSO mask to set hw_features(or features),
> but have to explicitly set offload option. Because, This would make drivers automatically
> clain to support any new TSO feature an the moment of NETIF_F_ALL_TSO is expanded.
> 
> Some code style tuning. Just compile test. 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

But loopback is special.  It can support anything the kernel stack can emit.

So for loopback, using NETIF_F_ALL_TSO is in fact appropriate.
