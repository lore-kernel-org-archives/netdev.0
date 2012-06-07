From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Thu, 07 Jun 2012 16:01:50 +0200
Message-ID: <1339077710.5083.12.camel@edumazet-glaptop>
References: <jqo7op$t6f$1@dough.gmane.org>
	 <1339008142.26966.40.camel@edumazet-glaptop> <jqo9a6$ah6$1@dough.gmane.org>
	 <20120606.120247.1618312724057709285.davem@davemloft.net>
	 <jqqa1b$kug$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Grant Edwards <grant.b.edwards@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61950 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932367Ab2FGOB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 10:01:58 -0400
Received: by eeit10 with SMTP id t10so246978eei.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 07:01:56 -0700 (PDT)
In-Reply-To: <jqqa1b$kug$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-07 at 13:23 +0000, Grant Edwards wrote:
> On 2012-06-06, David Miller <davem@davemloft.net> wrote:
> > From: Grant Edwards <grant.b.edwards@gmail.com>
> > Date: Wed, 6 Jun 2012 18:59:19 +0000 (UTC)
> >
> >> At the time it was written (probably 10+ years ago) it was relying on
> >> the documented API for alloc_skb() that stated alloc_skb() either
> >> returned an sk_buff of the requested size or it failed.
> >
> > It was never a formal API that we would only allocate 'size'
> > amount of tailroom.
> 
> How can you say that?


Documentation was stale, so what ?

kmalloc(99) doesnt allocate 99 bytes but 128, so what ?

Grant, what about you fix your code ?
