From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dummy: add more features
Date: Wed, 21 Oct 2015 19:36:51 -0700 (PDT)
Message-ID: <20151021.193651.1239717859030712355.davem@davemloft.net>
References: <1445311079.30896.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269AbbJVCUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 22:20:25 -0400
In-Reply-To: <1445311079.30896.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Oct 2015 20:17:59 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While testing my SIT/GRO patch using netfilter TEE module and a dummy
> device, I found some features were missing :
> 
> TSO IPv6, UFO, and encapsulated traffic.
> 
> ethtool -k dummy0 now gives :
> ...
> tcp-segmentation-offload: on
> 	tx-tcp-segmentation: on
> 	tx-tcp-ecn-segmentation: on
> 	tx-tcp6-segmentation: on
> udp-fragmentation-offload: on
> ...
> tx-gre-segmentation: on
> tx-ipip-segmentation: on
> tx-sit-segmentation: on
> tx-udp_tnl-segmentation: on
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
