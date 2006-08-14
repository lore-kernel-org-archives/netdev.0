From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
Date: Mon, 14 Aug 2006 22:51:43 +1000
Message-ID: <E1GCbux-0005CO-00@gondolin.me.apana.org.au>
References: <44E06AC7.6090301@redhat.com>
Cc: johnpol@2ka.mipt.ru, phillips@google.com, a.p.zijlstra@chello.nl,
	indan@nul.nu, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20996 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1752017AbWHNMwT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 08:52:19 -0400
To: riel@redhat.com (Rik van Riel)
In-Reply-To: <44E06AC7.6090301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rik van Riel <riel@redhat.com> wrote:
> 
> That should not be any problem, since skb's (including cowed ones)
> are short lived anyway.  Allocating a little bit more memory is
> fine when we have a guarantee that the memory will be freed again
> shortly.

I'm not sure about the context the comment applies to, but skb's are
not necessarily short-lived.  For example, they could be queued for
a few seconds for ARP/NDISC and even longer for IPsec SA resolution.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
