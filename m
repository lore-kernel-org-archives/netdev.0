From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable 1/2] l2tp: Fix PPP header erasure and memory
 leak
Date: Thu, 13 Jun 2013 02:39:28 -0700 (PDT)
Message-ID: <20130613.023928.1403482279088039776.davem@davemloft.net>
References: <cover.1371044671.git.g.nault@alphalink.fr>
	<20130612140723.GB3500@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756248Ab3FMJj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:39:29 -0400
In-Reply-To: <20130612140723.GB3500@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 12 Jun 2013 16:07:23 +0200

> Copy user data after PPP framing header. This prevents erasure of the
> added PPP header and avoids leaking two bytes of uninitialised memory
> at the end of skb's data buffer.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied.
