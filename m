From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] ipv6: Handle PMTU in ICMP error handlers.
Date: Fri, 15 Jun 2012 22:42:25 -0400
Message-ID: <CADVnQyn+t8VjgqqACDvSDR3yMN-q8xntGwVwWNxB4TFLxUYU8g@mail.gmail.com>
References: <20120615.150052.774388947489484043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:48413 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755461Ab2FPCm1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 22:42:27 -0400
Received: by ghrr11 with SMTP id r11so2842108ghr.19
        for <netdev@vger.kernel.org>; Fri, 15 Jun 2012 19:42:26 -0700 (PDT)
In-Reply-To: <20120615.150052.774388947489484043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 15, 2012 at 6:00 PM, David Miller <davem@davemloft.net> wro=
te:
> +++ b/include/net/ip6_route.h
> +extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __=
be32 mtu,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int oif, u32 ma=
rk);
=2E..
> +++ b/net/ipv6/route.c
> +void ip6_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int oif, __be32 mark)

The .h and .c files disagree on the types of mtu and mark for
ip6_update_pmtu(). Looks like the mtu should be __be32 in both. I'm
guessing mark should also be __be32 in both, though I'm not yet
familiar with that area of the code.

Otherwise looks great to me.

neal
