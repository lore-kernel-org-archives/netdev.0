From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: ip_send_unicast_reply() is not BH
 safe
Date: Fri, 06 May 2016 16:03:08 -0400 (EDT)
Message-ID: <20160506.160308.392258128417213365.davem@davemloft.net>
References: <1462553178.13075.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreslc@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758232AbcEFUDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:03:11 -0400
In-Reply-To: <1462553178.13075.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 May 2016 09:46:18 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I forgot that ip_send_unicast_reply() is not BH safe (yet).
> 
> Disabling preemption before calling it was not a good move.
> 
> Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andres Lagar-Cavilla  <andreslc@google.com>

Applied, thanks.
