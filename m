From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Don't purge default router if accept_ra=2
Date: Mon, 04 Mar 2013 14:15:23 -0500 (EST)
Message-ID: <20130304.141523.1388472753163504139.davem@davemloft.net>
References: <CAKD1Yr2e8Z8CDAM3tgp=nUR58OO9QZYEx8zkWwwcQ1S=14D2Qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758520Ab3CDTPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 14:15:25 -0500
In-Reply-To: <CAKD1Yr2e8Z8CDAM3tgp=nUR58OO9QZYEx8zkWwwcQ1S=14D2Qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Mon, 4 Mar 2013 15:46:46 +0900

> Setting net.ipv6.conf.<interface>.accept_ra=2 causes the kernel
> to accept RAs even when forwarding is enabled. However, enabling
> forwarding purges all default routes on the system, breaking
> connectivity until the next RA is received. Fix this by not
> purging default routes on interfaces that have accept_ra=2.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied and queued up for -stable.
