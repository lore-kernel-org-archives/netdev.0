From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Mon, 4 Nov 2013 16:55:30 +0000
Message-ID: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
References: <20131029090849.GC5944@cpaasch-mac>
	 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	<christoph.paasch@uclouvain.be>, <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>, <hkchu@google.com>, <mwdalton@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52614 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278Ab3KDQzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 11:55:35 -0500
In-Reply-To: <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-02 at 12:58 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
> by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> 
> skb_segment() only deals with a frag_list chain containing MSS sized
> fragments. Even if we fix this problem, its better if GRO layer
> doesn't build skb with a frag_list in the first place, to let TSO
> packets reaching output devices.
>  
> David Miller and Ben Hutchings suggested we keep track of number of
> forwarding users to be able to :
> 
> - Disable LRO
> - Make sure GRO layer do not use skb frag_list to extend skb capacity
> 
> Note that after this patch, LRO is automatically re-enabled if
> forwarding is disabled on the device, or if a device is removed
> from a bridge.
[...]

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
