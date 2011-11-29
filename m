From: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 16:03:42 -0700 (Mountain Standard Time)
Message-ID: <alpine.WNT.2.00.1111291600220.228@TSI>
References: <alpine.WNT.2.00.1111291027320.1036@TSI> <1322589661.2596.2.camel@edumazet-laptop> <1322599437.2596.10.camel@edumazet-laptop> <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com> <1322599991.2596.11.camel@edumazet-laptop>
 <alpine.WNT.2.00.1111291359290.1036@TSI> <1322601444.2596.21.camel@edumazet-laptop> <1322602283.2596.25.camel@edumazet-laptop> <alpine.WNT.2.00.1111291527360.228@TSI> <1322606542.2596.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="2519437-12775-1322607824=:228"
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1322606542.2596.43.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--2519437-12775-1322607824=:228
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

On Tue, 29 Nov 2011, Eric Dumazet wrote:
> Le mardi 29 novembre 2011 à 15:32 -0700, Marc Aurele La France a écrit :
>> But your audit is incomplete, a grep of 3.1.3 for dst_get_neighbour() and
>> dst_get_neighbour_raw() reveals occurrences in ...

>> include/net/dst.h
>> net/atm/clip.c
>> net/sched/sch_teql.c
>> net/core/neighbour.c
>> net/ipv4/ip_gre.c
>> net/ipv4/ip_output.c
>> net/ipv4/route.c
>> net/xfrm/xfrm_policy.c
>> net/bridge/br_netfilter.c
>> net/decnet/dn_neigh.c
>> net/decnet/dn_route.c
>> net/ipv6/sit.c
>> net/ipv6/addrconf.c
>> net/ipv6/route.c
>> net/ipv6/ndisc.c
>> net/ipv6/ip6_output.c
>> net/ipv6/ip6_fib.c

> All these are already covered, or else bad things would already
> happened.

No, only warnings (splats as you call them) would be produced.  The fact 
is you added side-effects to dst_get_neighbour(), and I would expect all 
its invocations to be affected.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
--2519437-12775-1322607824=:228--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
