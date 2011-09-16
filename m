From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Send ICMPv6 RSes only when RAs are accepted
Date: Fri, 16 Sep 2011 19:15:15 -0400 (EDT)
Message-ID: <20110916.191515.1019538386382326179.davem@davemloft.net>
References: <4E73C2E5.2050901@fud.no>
	<20110916.174900.961553137813655280.davem@davemloft.net>
	<4E73C8B1.70404@fud.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tore@fud.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850Ab1IPXQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 19:16:22 -0400
In-Reply-To: <4E73C8B1.70404@fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tore Anderson <tore@fud.no>
Date: Sat, 17 Sep 2011 00:07:45 +0200

> * David Miller
> 
>>> I'm not removing accept_ra==2, no, only forwarding==2. Or, more
>>> precisely, I'm only removing the *documentation* for forwarding==2;
>>> forwarding==2 will still work, but there's no difference from
>>> forwarding==1 any longer.
>> 
>> Ok, please make this more clear in your commit message.
> 
> I actually did improve the commit message in this regard when I re-sent
> the patch, see <http://patchwork.ozlabs.org/patch/113625/>. Is that one
> good enough?

Looks good, applied, thanks!
