From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] geneve: initialize needed_headroom
Date: Wed, 23 Dec 2015 22:28:59 -0500 (EST)
Message-ID: <20151223.222859.26644566083507428.davem@davemloft.net>
References: <211eb876be50613e662c0f01c3de6735e23e9b97.1450885903.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, jbenc@redhat.com,
	jesse@nicira.com, hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbbLXD3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 22:29:01 -0500
In-Reply-To: <211eb876be50613e662c0f01c3de6735e23e9b97.1450885903.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 23 Dec 2015 16:54:27 +0100

> Currently the needed_headroom field for the geneve device is left
> to the default value.
> 
> This patch set it to space required for basic geneve encapsulation,
> so that we can avoid the skb head re-allocation on xmit.
> 
> This give a 6% speedup for unsegment traffic on geneve tunnel.
> 
> v1 -> v2:
>   - add ETH_HLEN for the lower device to the needed headroom
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thank you.
