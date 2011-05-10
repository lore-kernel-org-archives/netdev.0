From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] netdevice.h: Align struct netdevices members
Date: Mon, 09 May 2011 21:22:05 -0700
Message-ID: <1305001325.19586.110.camel@Joe-Laptop>
References: <1304998966.19586.104.camel@Joe-Laptop>
	 <1304999595.3050.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1436 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750812Ab1EJEWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 00:22:06 -0400
In-Reply-To: <1304999595.3050.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-10 at 05:53 +0200, Eric Dumazet wrote:
> Le lundi 09 mai 2011 =C3=A0 20:42 -0700, Joe Perches a =C3=A9crit :
> > Save a bit of space.
> Hmm... correct alignements are far more important for this structure.

I agree.  I aligned these members on "natural" boundaries.
4 consecutive chars rather than 2 chars, unsigned long.
=20
> Did you run benchmarks on 32bit and 64bit platforms ?

Nope.

> BTW we have ____cacheline_aligned_in_smp markers, I am not even sure
> this patch saves space.

That depends on whether or not CONFIG_SMP is defined and
all of the changes are before any ____cacheline_aligned markers.


