From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same
Date: Thu, 3 Oct 2002 16:18:53 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210031617360.8536-100000@netcore.fi>
References: <20021003.060254.26942488.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20021003.060254.26942488.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Oct 2002, David S. Miller wrote:
>    From: kuznet@ms2.inr.ac.ru
>    Date: Thu, 3 Oct 2002 17:06:48 +0400 (MSD)
> 
>    No, really! __Sharing__ of port space between IPv4 and IPv6 was mad
>    idea. It cannot generalized to other protocol families.
>    
>    So, IPV6_V6ONLY is really unique for IPv6. Well, actually, it could
>    be negated: be default and the option would be called
>    IPV6_SHARE_THIS_PORT_TO_IPV4.
> 
> I think what I want to really say is that I want to provide
> way for ipv4 application to say "no ipv6 connections on this
> listening socket please".
> 
> So does it make no sense at all to have IP_V4ONLY?

Umm, I think an app guy can do that with creating an AF_INET socket; there 
will not be IPv6 there.  Folks Who Think They Know Best decided that dual 
use for AF_INET6 would be best, and IPV6_V6ONLY was invented (note: it'd 
already implemented by some others) to repair that.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
