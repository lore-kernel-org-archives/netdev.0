From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
Date: Mon, 14 Aug 2006 10:22:40 -0400
Message-ID: <44E08730.8080702@redhat.com>
References: <E1GCbux-0005CO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, phillips@google.com, a.p.zijlstra@chello.nl,
	indan@nul.nu, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56489 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932456AbWHNOXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 10:23:05 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GCbux-0005CO-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Rik van Riel <riel@redhat.com> wrote:
>> That should not be any problem, since skb's (including cowed ones)
>> are short lived anyway.  Allocating a little bit more memory is
>> fine when we have a guarantee that the memory will be freed again
>> shortly.
> 
> I'm not sure about the context the comment applies to, but skb's are
> not necessarily short-lived.  For example, they could be queued for
> a few seconds for ARP/NDISC and even longer for IPsec SA resolution.

That's still below the threshold where it should cause problems
with the VM going OOM.  Especially if there aren't too many of
these packets.

-- 
All Rights Reversed
