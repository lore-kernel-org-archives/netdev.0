From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: take care of cloned skbs in
 tcp_try_coalesce()
Date: Wed, 02 May 2012 21:11:47 -0400 (EDT)
Message-ID: <20120502.211147.1622167790503932925.davem@davemloft.net>
References: <4FA1606A.6040607@intel.com>
	<1335977179.22133.599.camel@edumazet-glaptop>
	<1335981358.22133.605.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	jeffrey.t.kirsher@intel.com, mchan@broadcom.com,
	mcarlson@broadcom.com, herbert@gondor.hengli.com.au,
	bhutchings@solarflare.com, ilpo.jarvinen@helsinki.fi,
	maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849Ab2ECBMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 21:12:05 -0400
In-Reply-To: <1335981358.22133.605.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 May 2012 19:55:58 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Before stealing fragments or skb head, we must make sure skbs are not
> cloned.
> 
> Alexander was worried about destination skb being cloned : In bridge
> setups, a driver could be fooled if skb->data_len would not match skb
> nr_frags.
> 
> If source skb is cloned, we must take references on pages instead.
> 
> Bug happened using tcpdump (if not using mmap())
> 
> Introduce kfree_skb_partial() helper to cleanup code.
> 
> Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
