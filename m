From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same
Date: Thu, 03 Oct 2002 06:02:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.060254.26942488.davem@redhat.com>
References: <20021003.012904.75241727.davem@redhat.com>
	<200210031306.RAA29293@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200210031306.RAA29293@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Thu, 3 Oct 2002 17:06:48 +0400 (MSD)

   No, really! __Sharing__ of port space between IPv4 and IPv6 was mad
   idea. It cannot generalized to other protocol families.
   
   So, IPV6_V6ONLY is really unique for IPv6. Well, actually, it could
   be negated: be default and the option would be called
   IPV6_SHARE_THIS_PORT_TO_IPV4.

I think what I want to really say is that I want to provide
way for ipv4 application to say "no ipv6 connections on this
listening socket please".

So does it make no sense at all to have IP_V4ONLY?
