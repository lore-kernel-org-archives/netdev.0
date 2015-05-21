From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Better handling of transition to NUD_PROBE
 state
Date: Thu, 21 May 2015 16:53:32 -0400 (EDT)
Message-ID: <20150521.165332.1552040068826483613.davem@davemloft.net>
References: <1431945881-14707-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, lorenzo@google.com,
	netdev@vger.kernel.org
To: ek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756217AbbEUUxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 16:53:34 -0400
In-Reply-To: <1431945881-14707-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Kline <ek@google.com>
Date: Mon, 18 May 2015 19:44:41 +0900

> [1] When entering NUD_PROBE state via neigh_update(), perhaps received
>     from userspace, correctly (re)initialize the probes count to zero.
> 
>     This is useful for forcing revalidation of a neighbor (for example
>     if the host is attempting to do DNA [IPv4 4436, IPv6 6059]).
> 
> [2] Notify listeners when a neighbor goes into NUD_PROBE state.
> 
>     By sending notifications on entry to NUD_PROBE state listeners get
>     more timely warnings of imminent connectivity issues.
> 
>     The current notifications on entry to NUD_STALE have somewhat
>     limited usefulness: NUD_STALE is a perfectly normal state, as is
>     NUD_DELAY, whereas notifications on entry to NUD_FAILURE come after
>     a neighbor reachability problem has been confirmed (typically after
>     three probes).
> 
> Signed-off-by: Erik Kline <ek@google.com>

Please, in the future, put a proper subsystem prefix in the Subject
line of your patch submissions.  In this particular case "neigh: "
would have been appropriate and is what I added when applying your
patch.

Applied, thanks.
