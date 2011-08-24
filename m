From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Pseudo-header required for the checksum of
 ICMP6 header of MLD
Date: Tue, 23 Aug 2011 22:06:32 -0700 (PDT)
Message-ID: <20110823.220632.1260999487287809298.davem@davemloft.net>
References: <4E53B360.8090107@sfc.wide.ad.jp>
	<4E53E237.1060401@sfc.wide.ad.jp>
	<4E54846D.10906@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	linus.luessing@web.de, herbert@gondor.hengli.com.au,
	yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org
To: wcang@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab1HXFHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 01:07:49 -0400
In-Reply-To: <4E54846D.10906@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Date: Wed, 24 Aug 2011 13:56:13 +0900

> @@ -1528,9 +1528,12 @@ static int br_multicast_ipv6_rcv(struct
> net_bridge *br,
>              break;
>          /*FALLTHROUGH*/
>      case CHECKSUM_NONE:
> -        skb2->csum = 0;
> -        if (skb_checksum_complete(skb2))
> + if (!skb_csum_unnecessary(skb2) && csum_ipv6_magic(&ip6h->saddr,
> + &ip6h->daddr, skb2->len, IPPROTO_ICMPV6,

Patch has been significantly corrupted by your email client, making
it unusable for us.

Please read linux/Documentation/email-clients.txt, email a test patch
to yourself, and only resend your patch to this list once you can
successfully apply such a patch yourself.
