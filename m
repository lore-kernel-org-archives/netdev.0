From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: consistent use of IP6_INC_STATS_BH() in ip6_forward()
Date: Fri, 6 Dec 2013 15:07:33 +0100
Message-ID: <20131206140733.GB7108@order.stressinduktion.org>
References: <1386308286.30495.227.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36233 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161348Ab3LFOHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 09:07:34 -0500
Content-Disposition: inline
In-Reply-To: <1386308286.30495.227.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 09:38:06PM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> ip6_forward() runs from softirq context, we can use the SNMP macros
> assuming this.
> 
> Use same indentation for all IP6_INC_STATS_BH() calls.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
