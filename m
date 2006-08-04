From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: problems with e1000 and jumboframes
Date: Fri, 04 Aug 2006 15:59:37 +1000
Message-ID: <E1G8sif-0003oY-00@gondolin.me.apana.org.au>
References: <41b516cb0608031334s6e159e99tb749240f44ae608d@mail.gmail.com>
Cc: arnd@arndnet.de, johnpol@2ka.mipt.ru, olel@ans.pl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35598 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161061AbWHDF7z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 01:59:55 -0400
To: chris.leech@gmail.com (Chris Leech)
In-Reply-To: <41b516cb0608031334s6e159e99tb749240f44ae608d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <chris.leech@gmail.com> wrote:
> 
> We could try and only use page allocations for older e1000 devices,
> putting headers and payload into skb->frags and copying the headers
> out into the skb->data area as needed for processing.  That would do
> away with large allocations, but in Jesse's experiments calling
> alloc_page() is slower than kmalloc(), so there can actually be a
> performance hit from trying to use page allocations all the time.

Interesting.  Could you guys post figures on alloc_page speed vs. kmalloc?

Also, getting memory slower is better than not getting them at all :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
