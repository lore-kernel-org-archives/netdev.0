From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] udp: udp_sendmsg() fix
Date: Thu, 03 Mar 2011 10:42:26 -0800 (PST)
Message-ID: <20110303.104226.71110201.davem@davemloft.net>
References: <1299169686.2983.129.camel@edumazet-laptop>
	<1299172043.2983.142.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57059
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752435Ab1CCSlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 13:41:49 -0500
In-Reply-To: <1299172043.2983.142.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Mar 2011 18:07:23 +0100

> [PATCH net-next-2.6] udp: udp_sendmsg() fix
> 
> commit b23dd4fe42b455af (ipv4: Make output route lookup return rtable
> directly) introduced a regression in udp_sendmsg()
> 
> If IP route lookup fails, we should not try to release an non existent
> route.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Ok, this works too.

My version NULL's out rt, so that if we had any changes in code paths
here it would be unlikely we'd reintroduce this bug.

I'm fine either way, although my version is in net-next-2.6 at the
moment :-)
