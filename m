From: Ville Nuorvala <vnuorval@morphine.tml.hut.fi>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.43
Date: Fri, 18 Oct 2002 02:52:48 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0210180158330.18554-100000@morphine.tml.hut.fi>
References: <20021018.021802.87011078.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: ajtuomin@morphine.tml.hut.fi, <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>,
   <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>, <pekkas@netcore.fi>,
   <torvalds@transmeta.com>, <jagana@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021018.021802.87011078.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, 18 Oct 2002, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> In article <20021017162624.GC16370@morphine.tml.hut.fi> (at Thu, 17 Oct 2002 19:26:25 +0300), Antti Tuominen <ajtuomin@morphine.tml.hut.fi> says:
>
> [ipv6_tunnel]
>
> I think this is almost ok.
>
>   1. I believe s/ARPHRD_IPV6_IPV6_TUNNEL/ARPHRD_TUNNEL6/.

Ok by me! The comment of course says IPIP6 tunnel at the moment, but the
constant itself doesn't appear to be used anywhere.

>   2. Please put outer address to hardware address in dev.

The reason I haven't done this is that MAX_ADDR_LEN is just 8. Does anyone
have any objections against changing the value to 16?

>      Note: you need to modify SIOxxx ioctls too not to overrun!

Sorry, I'm not that familiar with ioctls, I just copied the basic
functionality from sit.c. Could you explain it a bit more thoroughly, so
even I with my thick skull understand what the problem is?


-Ville

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tml.hut.fi, phone: +358 (0)9 451 5257
