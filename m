From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Default Route Support on Router
Date: Mon, 30 Sep 2002 18:56:36 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209301456.SAA15178@sex.inr.ac.ru>
References: <20020928.231915.113302934.davem@redhat.com>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.ORG, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20020928.231915.113302934.davem@redhat.com> from "David S. Miller" at Sep 28, 2 11:19:15 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Oh I see... perhaps you imply I should destroy CONFIG_RT6_POLICY
> remnants as well? :-)

Yes, the bits in route.c must be killed.

But I would prefer to preserve subtrees support in ip6_fib.c.
It is... well, it really constrains hacking, but in a useful manner,
not allowing to forget that a radix node may open second level lookup.

Alexey
