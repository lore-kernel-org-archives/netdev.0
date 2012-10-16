From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: fix /proc/net/if_inet6
Date: Tue, 16 Oct 2012 14:55:51 -0400 (EDT)
Message-ID: <20121016.145551.1060498449362372128.davem@davemloft.net>
References: <1350405787.3954.1229.camel@edumazet-glaptop>
	<1350406522.3954.1242.camel@edumazet-glaptop>
	<1350409047.3954.1295.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: janhinnerk.stosch@gmail.com, netdev@vger.kernel.org,
	mihai.maruseac@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681Ab2JPSzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 14:55:53 -0400
In-Reply-To: <1350409047.3954.1295.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Oct 2012 19:37:27 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 1d5783030a1 (ipv6/addrconf: speedup /proc/net/if_inet6 filling)
> added bugs hiding some devices from if_inet6 and breaking applications.
> 
> "ip -6 addr" could still display all IPv6 addresses, while "ifconfig -a"
> couldnt.
> 
> One way to reproduce the bug is by starting in a shell :
> 
> unshare -n /bin/bash
> ifconfig lo up
> 
> And in original net namespace, lo device disappeared from if_inet6
> 
> Reported-by: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Mihai Maruseac <mihai.maruseac@gmail.com>

Applied and queued up for -stable, thanks.
