From: David Miller <davem@davemloft.net>
Subject: Re: Adding inode field to /proc/net/netlink
Date: Sun, 28 Feb 2010 01:28:34 -0800 (PST)
Message-ID: <20100228.012834.15245196.davem@davemloft.net>
References: <20100228.144537.445518512048328806.yamato@redhat.com>
	<20100228.010057.229746532.davem@davemloft.net>
	<1267348431.9082.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yamato@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031664Ab0B1J2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 04:28:17 -0500
In-Reply-To: <1267348431.9082.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 28 Feb 2010 10:13:51 +0100

> Hmm we already did such expansion last year with commit 38938bfe when
> Pablo Neira Ayuso added the Drops column
> 
> Extract of its Changelog :
> 
>  This patch also includes the use of sk_drop to account the number of
>  netlink messages drop due to overrun. This value is shown in
>  /proc/net/netlink.
> 
> So yes, some applications might break but they probably already broke
> one year ago and their maintainers should know that adding new fields at
> the end of lines is expected ?
> 
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

That's a good point.

Ok, I'll apply this.

Thanks.
