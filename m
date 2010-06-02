From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 10:31:02 -0700 (PDT)
Message-ID: <20100602.103102.121237521.davem@davemloft.net>
References: <1275496439.2725.203.camel@edumazet-laptop>
	<alpine.DEB.2.00.1006021140320.30182@router.home>
	<20100602.101258.134121018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58027
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756370Ab0FBRaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 13:30:52 -0400
In-Reply-To: <20100602.101258.134121018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just in case people are really so clueless as to be unable to figure
this out:

echo 1 >/sys/kernel/debug/tracing/events/skb/kfree_skb/enable
...do some stuff...
cat /sys/kernel/debug/tracing/trace

You can even trace it using 'perf' by passing "skb:kfree_skb"
as the event specifier.
