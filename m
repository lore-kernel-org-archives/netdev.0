From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: warn user for preferred
 ip_local_port_range
Date: Wed, 27 May 2015 14:37:22 -0400 (EDT)
Message-ID: <20150527.143722.1854988910324788026.davem@davemloft.net>
References: <1432751677.4060.423.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbbE0ShX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:37:23 -0400
In-Reply-To: <1432751677.4060.423.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 May 2015 11:34:37 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 07f4c90062f8f ("tcp/dccp: try to not exhaust
> ip_local_port_range in connect()") it is advised to have an even number
> of ports described in /proc/sys/net/ipv4/ip_local_port_range
> 
> This means start/end values should have a different parity.
> 
> Let's warn sysadmins of this, so that they can update their settings
> if they want to.
> 
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
