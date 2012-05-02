From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Wed, 02 May 2012 18:19:38 +0200
Message-ID: <1335975578.22133.580.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
	 <1335891892.22133.23.camel@edumazet-glaptop>  <4FA03D69.6060907@intel.com>
	 <1335947084.22133.134.camel@edumazet-glaptop>  <4FA15DDE.5090904@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45906 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab2EBQTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 12:19:46 -0400
Received: by bkcji2 with SMTP id ji2so616652bkc.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 09:19:45 -0700 (PDT)
In-Reply-To: <4FA15DDE.5090904@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 09:16 -0700, Alexander Duyck wrote:

> I was working with the out-of-tree ixgbe because I have the option there
> of stripping out FCoE and RSC via a couple of build flags.  The problem
> is I don't know if the head frag stuff will work out very well with
> ixgbe because RSC and FCoE require that we have to use 1K aligned
> receive buffers.  It would require us to make us have to bump up our
> allocation size by NET_SKB_PAD plus skb_shared_info which would likely
> force us up to order 1 pages on most platforms.

What is RSC exactly, and why RSC is used in the build_skb() context ?
