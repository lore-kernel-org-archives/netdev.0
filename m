From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 02:43:00 -0700 (PDT)
Message-ID: <20120626.024300.1103735049445046458.davem@davemloft.net>
References: <1340700408.10893.275.camel@edumazet-glaptop>
	<20120626.015612.985388265386248330.davem@davemloft.net>
	<1340701893.10893.296.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab2FZJnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 05:43:04 -0400
In-Reply-To: <1340701893.10893.296.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Jun 2012 11:11:33 +0200

> I think I stopped trying to improve route cache because your intention
> was to get rid of it.
> 
> Now it seems we should keep it for a while, so it makes sense to add
> more fuel on it ;)

Removal is a long term project, so we can still make some short-
term tweaks :-)

> About financial guys, they probably are smart enough to :
> 
> echo bigvalue >/proc/sys/net/ipv4/route/gc_timeout

Every excess knob adjustment is a failure on our part.
