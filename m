From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] gro: should aggregate frames without DF
Date: Fri, 31 May 2013 14:12:13 -0700
Message-ID: <1370034733.5109.110.camel@edumazet-glaptop>
References: <1370019752.5109.108.camel@edumazet-glaptop>
	 <1370030944.2703.17.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:63749 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757138Ab3EaVMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 17:12:15 -0400
Received: by mail-pb0-f41.google.com with SMTP id xb12so2855689pbc.28
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 14:12:15 -0700 (PDT)
In-Reply-To: <1370030944.2703.17.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-31 at 21:09 +0100, Ben Hutchings wrote:

> But this results in ignoring the actual offset bits of frag_off!
> We should allow merging only if all packets have frag_off == IP_DF or
> all have frag_off == 0.  The first assignment of flush therefore still
> needs to check the combined id/frag_off word, but using (id & ~IP_DF)
> instead of (id ^ IP_DF).

You're right, I guess I wanted too much getting rid of black magic in
this code ;)

I'll send a v2
