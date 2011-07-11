From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 1/2] net: introduce
 __netdev_alloc_skb_ip_align
Date: Mon, 11 Jul 2011 23:57:08 +0100
Message-ID: <1310425028.2707.12.camel@bwh-desktop>
References: <1310421164.2860.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37945 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab1GKW5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 18:57:12 -0400
In-Reply-To: <1310421164.2860.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-07-11 at 23:52 +0200, Eric Dumazet wrote:
> RX rings should use GFP_KERNEL allocations if possible, add
> __netdev_alloc_skb_ip_align() helper to ease this.
[...]

When it is possible, other than when starting an interface?  RX refill
normally has to be done in NAPI context or at least synchronised with
NAPI, so GFP_ATOMIC is required.  Not sure how much point there is in
making a special case for the initial fill.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

