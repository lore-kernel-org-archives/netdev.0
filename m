From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Sun, 15 May 2011 13:20:50 -0700
Message-ID: <1305490850.8178.57.camel@Joe-Laptop>
References: <20110513171729.247b126e@nehalam>
	 <1305488809.3120.162.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1638 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378Ab1EOUUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2011 16:20:51 -0400
In-Reply-To: <1305488809.3120.162.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-05-15 at 21:46 +0200, Eric Dumazet wrote:
> Le vendredi 13 mai 2011 =C3=A0 17:17 -0700, Stephen Hemminger a =C3=A9=
crit :
> > There are some addresses in the assigned vendor block that don't ob=
ey
> > the locally assigned convention. These should be avoided by random_=
ether_addr
> > assignment.
> We call random_ether_addr() for some virtual devices, maybe we can ad=
d a
> __random_ether_addr() helper for them and not avoid these OUI ?

Unless it's speed critical, it's probably not worthwhile.

I think that using get_random_bytes, because it can drain
the entropy pool, may not be a great thing to do.

There's little value in crypto secure OUI's for random
ethernet addresses.

I think using get_random_int or random32 is probably good
enough.

