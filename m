From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same
Date: Thu, 3 Oct 2002 17:06:48 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210031306.RAA29293@sex.inr.ac.ru>
References: <20021003.012904.75241727.davem@redhat.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.COM (David S. Miller)
In-Reply-To: <20021003.012904.75241727.davem@redhat.com> from "David S. Miller" at Oct 3, 2 12:45:01 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> For example, this IPV6_V6ONLY socket option is flawed.  What we
> really need is a generic socket option which says "my family only"
> 
> There is nothing ipv6 specific about such a socket attribute.
> 
> So please, create instead "SO_ONEFAMILY" or similar generic
> socket option.

No, really! __Sharing__ of port space between IPv4 and IPv6 was mad
idea. It cannot generalized to other protocol families.

So, IPV6_V6ONLY is really unique for IPv6. Well, actually, it could
be negated: be default and the option would be called
IPV6_SHARE_THIS_PORT_TO_IPV4.

Alexey
