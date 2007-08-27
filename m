From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] netdevice: kernel docbook addition
Date: Mon, 27 Aug 2007 14:18:53 +0200
Message-ID: <20070827121853.GA2854@ff.dom.local>
References: <20070822123314.785dea2a@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S\. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:57630 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750718AbXH0MRi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 08:17:38 -0400
Content-Disposition: inline
In-Reply-To: <20070822123314.785dea2a@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22-08-2007 21:33, Stephen Hemminger wrote:
> Add more kernel doc's for part of the network device API.
> This is only a start, and needs more work.
> 
> Applies against net-2.6.24
...
> +/**
> + *	napi_disable - prevent NAPI from scheduling
> + *	@n: napi context
> + *
> + * Resume NAPI from being scheduled on this context.
> + * Must be paired with napi_disable.
> + */
>  static inline void napi_enable(struct napi_struct *n)
>  {

It looks like small fix is needed here (I hope it would be faster
without my patch, thanks).

Jarek P.
