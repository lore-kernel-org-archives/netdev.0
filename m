From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Thu, 7 Jun 2012 13:23:55 +0000 (UTC)
Message-ID: <jqqa1b$kug$1@dough.gmane.org>
References: <jqo7op$t6f$1@dough.gmane.org>
 <1339008142.26966.40.camel@edumazet-glaptop> <jqo9a6$ah6$1@dough.gmane.org>
 <20120606.120247.1618312724057709285.davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37378 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756125Ab2FGNYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2012 09:24:10 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Scch5-00015L-2M
	for netdev@vger.kernel.org; Thu, 07 Jun 2012 15:24:07 +0200
Received: from dsl.comtrol.com ([64.122.56.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 15:24:07 +0200
Received: from grant.b.edwards by dsl.comtrol.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 15:24:07 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-06-06, David Miller <davem@davemloft.net> wrote:
> From: Grant Edwards <grant.b.edwards@gmail.com>
> Date: Wed, 6 Jun 2012 18:59:19 +0000 (UTC)
>
>> At the time it was written (probably 10+ years ago) it was relying on
>> the documented API for alloc_skb() that stated alloc_skb() either
>> returned an sk_buff of the requested size or it failed.
>
> It was never a formal API that we would only allocate 'size'
> amount of tailroom.

How can you say that?

>From skbuff.c:

    /**
    *__alloc_skb-allocate a network buffer
    *@size: size to allocate
    *@gfp_mask: allocation mask
    *@fclone: allocate from fclone cache instead of head cache
    *and allocate a cloned (child) skb
    *@node: numa node to allocate memory on
    *
>>> *Allocate a new &sk_buff. The returned buffer has no headroom and a
>>> *tail room of size bytes. The object has a reference count of one.
    *The return is the buffer. On a failure the return is %NULL.
    *
    *Buffers may only be allocated from interrupts using a @gfp_mask of
    *%GFP_ATOMIC.
    */

-- 
Grant Edwards               grant.b.edwards        Yow! Did you move a lot of
                                  at               KOREAN STEAK KNIVES this
                              gmail.com            trip, Dingy?
