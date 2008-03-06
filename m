From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4]: Add an 'rtable' field in struct sk_buff to alias 'dst'
 field and avoid casts
Date: Wed, 05 Mar 2008 18:35:39 -0800 (PST)
Message-ID: <20080305.183539.76566188.davem@davemloft.net>
References: <47CCFC0B.7060801@cosmosbay.com>
	<20080303.234649.109971767.davem@davemloft.net>
	<47CF2CFA.6000704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33645
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933097AbYCFCfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 21:35:40 -0500
In-Reply-To: <47CF2CFA.6000704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 06 Mar 2008 00:30:02 +0100

> [IPV4]: Add an 'rtable' field in struct sk_buff to alias 'dst' field and avoid 
> casts
> 
> (Anonymous) unions can help us to avoid ugly casts.
> 
> A common cast it the (struct rtable *)skb->dst one.
> 
> Defining an union like  :
> union {
>      struct dst_entry *dst;
>      struct rtable *rtable;
> };
> permits to use dkb->rtable in place.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 

Applied with some minor changelog tidy and typo fixups.

Please make your changelog entry header lines smaller in
the future.  People scan them in shortlog output and it's
less readable if it's wider than standard terminal widths.

Thank you.
