From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sat, 05 Feb 2005 19:50:39 +0900 (JST)
Message-ID: <20050205.195039.05988480.yoshfuji@linux-ipv6.org>
References: <20050205061110.GA18275@gondor.apana.org.au>
	<20050204221344.247548cb.davem@davemloft.net>
	<20050205064643.GA29758@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mirko.parthey@informatik.tu-chemnitz.de,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shemminger@osdl.org,
        yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
In-Reply-To: <20050205064643.GA29758@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050205064643.GA29758@gondor.apana.org.au> (at Sat, 5 Feb 2005 17:46:43 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> If we wanted to preserve the split device semantics, then we
> can create a local GC list in IPv6 so that it can search based
> on rt6i_idev as well as the other keys.  Alternatively we can
> remove the dst->dev == dev check in dst_dev_event and dst_ifdown
> and move that test down to the individual ifdown functions.

Yes, IPv6 needs "split device" semantics
(for per-device statistics such as Ip6InDelivers etc),
and I like later solution.

Thanks.

--yoshfuji
