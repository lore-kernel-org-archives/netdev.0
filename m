From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BK PATCH] Misc IPv6 Updates
Date: Wed, 10 Nov 2004 16:23:16 -0500 (EST)
Message-ID: <20041110.162316.116605012.yoshfuji@linux-ipv6.org>
References: <OF8CA84FB0.6990A5CD-ON88256F48.0063D0E6-88256F48.0064C53C@us.ibm.com>
	<419285B8.4070703@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kumarkr@us.ibm.com, davem@davemloft.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Brian.Haley@hp.com
In-Reply-To: <419285B8.4070703@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <419285B8.4070703@hp.com> (at Wed, 10 Nov 2004 16:18:48 -0500), Brian Haley <Brian.Haley@hp.com> says:

> > Is it faster to do :
> > 
> > +static inline int ipv6_addr_equal(const struct in6_addr *a1,
> > +   const struct in6_addr *a2)
> > +{
> > + return (a1->s6_addr32[3] == a2->s6_addr32[3] &&
> > + a1->s6_addr32[2] == a2->s6_addr32[2] &&
> > + a1->s6_addr32[1] == a2->s6_addr32[1] &&
> > + a1->s6_addr32[0] == a2->s6_addr32[0]);
> > +}
> > +
> > 
> > instead ?It should be faster for typical addresses, say 2000:a:b:c::1 
> > and 2000:a:b:c::2. The device EUI-64 is
> > normally going to be different for all devices while prefix can be same 
> > (atleast on a link/local site) completely
> > or to some prefix len portion.
:
> I will eventually do a 64-bit comparison to see if putting an
> #ifdef CONFIG_64BIT is worth it.

No, because we cannot assume 64bit alignment.

--yoshfuji
