From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: NIU driver: strange issues with multicast "UDP: short
	packet"
Date: Wed, 4 Feb 2009 22:52:48 +1100
Message-ID: <20090204115247.GA22028@gondor.apana.org.au>
References: <20090203.153853.163818774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jdb@comx.dk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59613 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751067AbZBDLwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 06:52:55 -0500
Content-Disposition: inline
In-Reply-To: <20090203.153853.163818774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> If the packet does get multicast forwarded, there is all kinds of
> funny code that mangles the packet, for example ipmr_cache_report().

That one looks alright since it'll either allocate a new skb
or at least do pskb_expand_head.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
