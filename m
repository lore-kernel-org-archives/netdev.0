From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 42012] New: regression on 2.6.39.3 with socket/bind;
 still there in 3.0.4
Date: Tue, 30 Aug 2011 18:57:20 -0400 (EDT)
Message-ID: <20110830.185720.533323490019157619.davem@davemloft.net>
References: <20110830.155219.431579142669857208.davem@davemloft.net>
	<1314734452.2556.12.camel@edumazet-laptop>
	<1314735562.2556.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	meissner@suse.de, r_meier@freenet.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab1H3XAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 19:00:07 -0400
In-Reply-To: <1314735562.2556.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Aug 2011 22:19:22 +0200

> [PATCH] net: ipv4: relax AF_INET check in bind()
> 
> commit d0733d2e29b65 (Check for mistakenly passed in non-IPv4 address)
> added regression on legacy apps that use bind() with AF_UNSPEC family.
> 
> Relax the check, but make sure the bind() is done on INADDR_ANY
> addresses, as AF_UNSPEC has probably no sane meaning for other
> addresses.
> 
> Bugzilla reference : https://bugzilla.kernel.org/show_bug.cgi?id=42012
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-and-bisected-by: Rene Meier <r_meier@freenet.de>
> CC: Marcus Meissner <meissner@suse.de>

Applied, thanks everyone.
