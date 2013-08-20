From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/3] net: ipv6: igmp6_event_query: use msecs_to_jiffies
Date: Tue, 20 Aug 2013 13:55:32 +0200
Message-ID: <20130820115532.GC3938@order.stressinduktion.org>
References: <1376994122-3022-1-git-send-email-dborkman@redhat.com> <1376994122-3022-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34579 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab3HTLzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 07:55:33 -0400
Content-Disposition: inline
In-Reply-To: <1376994122-3022-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 20, 2013 at 12:22:00PM +0200, Daniel Borkmann wrote:
> Use proper API functions to calculate jiffies from milliseconds and
> not the crude method of dividing HZ by a value. This ensures more
> accurate values even in the case of strange HZ values. While at it,
> also simplify code in the mlh2 case by using max().
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
