From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Discard and warn about LRO'd skbs received
 for forwarding
Date: Thu, 19 Jun 2008 16:27:27 -0700 (PDT)
Message-ID: <20080619.162727.153692540.davem@davemloft.net>
References: <cover.1213898165.git.bhutchings@solarflare.com>
	<20080619180833.GU5350@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	kmansley@solarflare.com, herbert@gondor.apana.org.au,
	shemminger@vyatta.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58754
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752811AbYFSX12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:27:28 -0400
In-Reply-To: <20080619180833.GU5350@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 19 Jun 2008 19:08:34 +0100

> Add skb_warn_if_lro() to test whether an skb was received with LRO and
> warn if so.
> 
> Change br_forward(), ip_forward() and ip6_forward() to call it) and
> discard the skb if it returns true.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Also applied to net-next-2.6

Thanks again Ben.
