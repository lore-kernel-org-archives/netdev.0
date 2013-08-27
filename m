From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/4] ps3_gelic: lower NAPI weight
Date: Tue, 27 Aug 2013 15:00:20 -0400 (EDT)
Message-ID: <20130827.150020.2001378358561747135.davem@davemloft.net>
References: <1377103771-1590-4-git-send-email-mschmidt@redhat.com>
	<1377118988.8674.82.camel@smoke>
	<5217667F.5010207@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geoff@infradead.org, netdev@vger.kernel.org, edumazet@google.com,
	sergei.shtylyov@cogentembedded.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab3H0TAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 15:00:24 -0400
In-Reply-To: <5217667F.5010207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri, 23 Aug 2013 15:41:19 +0200

> Since commit 82dc3c63 ("net: introduce NAPI_POLL_WEIGHT")
> netif_napi_add() produces an error message if a NAPI poll weight
> greater than 64 is requested.
> 
> GELIC_NET_NAPI_WEIGHT is defined to GELIC_NET_RX_DESCRIPTORS,
> which is 128.
> 
> Use the standard NAPI weight.
> 
> v2: proper reference to the related commit
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> Acked-by: Geoff Levand <geoff@infradead.org>

Applied.
