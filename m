From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: ipv6 and ipv4 interaction weirdness
Date: Fri, 11 Mar 2005 08:58:15 -0600 (CST)
Message-ID: <20050311.085815.100748583.yoshfuji@linux-ipv6.org>
References: <20050311121655.GE14146@zip.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: cat@zip.com.au
In-Reply-To: <20050311121655.GE14146@zip.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20050311121655.GE14146@zip.com.au> (at Fri, 11 Mar 2005 23:16:55 +1100), CaT <cat@zip.com.au> says:

> If it bound to :: port 22 then 0.0.0.0:22 would fail.
> 
> On the other hand if I got it to bind to each address individually then
> both ipv4 (2 addresses) and ipv6 (1 address) binds would succeed.
> 
> Maybe I'm just looking at it wrong but shouldn't ipv4 and ipv6 interfere
> with each other?

It is 100% intended, even it is not similar to BSD variants do.

IPv4 and IPv6 share address/port space.
:: and 0.0.0.0 is special "any" address, thus they confict.
::ffff:a.b.c.d and a.b.c.d also conflict.

--yoshfuji
