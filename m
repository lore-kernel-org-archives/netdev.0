From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4 net-next] net: make GRO aware of skb->head_frag
Date: Mon, 30 Apr 2012 19:54:06 +0200
Message-ID: <1335808446.2296.7.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59227 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754920Ab2D3RyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:54:12 -0400
Received: by eaaq12 with SMTP id q12so757655eaa.19
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 10:54:11 -0700 (PDT)
In-Reply-To: <1335523026.2775.236.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 12:37 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
...

> +		first_offset = skb->head -
> +			       (unsigned char *)page_address(page) +
> +			       offset;
> +
> +		pinfo->nr_frags = nr_frags + 1 + skbinfo->nr_frags;
> +

Oops. I realize this is a previous version of this patch.  

skb->head should be changed by skb->data here, I'll post a v2 for this
GRO change.
