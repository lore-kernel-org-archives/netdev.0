From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2] net: Introduce u64_stats_sync
 infrastructure
Date: Tue, 22 Jun 2010 10:24:55 -0700 (PDT)
Message-ID: <20100622.102455.232729115.davem@davemloft.net>
References: <1276598605.2541.96.camel@edumazet-laptop>
	<20100615110413.GJ6138@laptop>
	<1276608594.2541.119.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: npiggin@suse.de, netdev@vger.kernel.org, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53229
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756697Ab0FVRYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 13:24:44 -0400
In-Reply-To: <1276608594.2541.119.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Jun 2010 15:29:54 +0200

> diff --git a/include/linux/u64_stats_sync.h b/include/linux/u64_stats_sync.h
> index e69de29..5a4f318 100644
> --- a/include/linux/u64_stats_sync.h
> +++ b/include/linux/u64_stats_sync.h
> @@ -0,0 +1,107 @@
> +#ifndef _LINUX_U64_STATS_SYNC_H
> +#define _LINUX_U64_STATS_SYNC_H
> +

That's a really weird patch hunk for a newly added file.

The hunk header is saying that the new file start 1 line
in.  Which doesn't make any sense, and GIT reject this
saying that you're trying to make a modification to a
file which doesn't exist.

I applied this by hand, but I really wonder how you managed
to create such a patch :-)
