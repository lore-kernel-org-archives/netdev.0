From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv4: rcu conversion in
 ip_route_output_slow
Date: Thu, 30 Sep 2010 21:17:23 -0700 (PDT)
Message-ID: <20100930.211723.35808060.davem@davemloft.net>
References: <1285853638.2615.520.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48276
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388Ab0JAERC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 00:17:02 -0400
In-Reply-To: <1285853638.2615.520.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Sep 2010 15:33:58 +0200

> ip_route_output_slow() is enclosed in an rcu_read_lock() protected
> section, so that no references are taken/released on device, thanks to
> __ip_dev_find() & dev_get_by_index_rcu()
> 
> Tested with ip route cache disabled, and a stress test :
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, thanks!
