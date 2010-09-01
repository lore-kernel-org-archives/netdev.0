From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH net-next-2.6] gro: drivers should feed GRO only with
 TCP packets
Date: Wed, 1 Sep 2010 10:42:35 -0700
Message-ID: <20100901104235.5476a242@nehalam>
References: <1283360686.2556.381.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60852 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204Ab0IARmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 13:42:37 -0400
In-Reply-To: <1283360686.2556.381.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Sep 2010 19:04:46 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Many network devices can tell if an incoming frame is a TCP one for a
> small cost.
> 
> Instead of feeding GRO with all packets, we could filter packets on this
> information ?
> 
> This should help machines handling a mixed UDP/TCP workload, keeping gro
> overhead as small as possible.
> 
> patch against tg3 as an example...
> 
> Alternative would be to set a bit "is_tcp" on napi_struct to let this
> choice being done in network stack, not by each driver. 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

There was talk of doing GRO for UDP as well bug it never
got implemented. 


-- 
