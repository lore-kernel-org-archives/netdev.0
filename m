From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sat, 5 Feb 2005 20:02:42 -0800
Message-ID: <20050205200242.2b629de7.davem@davemloft.net>
References: <20050205061110.GA18275@gondor.apana.org.au>
	<20050204221344.247548cb.davem@davemloft.net>
	<20050205064643.GA29758@gondor.apana.org.au>
	<20050205.195039.05988480.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: herbert@gondor.apana.org.au, mirko.parthey@informatik.tu-chemnitz.de,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shemminger@osdl.org
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050205.195039.05988480.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 05 Feb 2005 19:50:39 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20050205064643.GA29758@gondor.apana.org.au> (at Sat, 5 Feb 2005 17:46:43 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:
> 
> > If we wanted to preserve the split device semantics, then we
> > can create a local GC list in IPv6 so that it can search based
> > on rt6i_idev as well as the other keys.  Alternatively we can
> > remove the dst->dev == dev check in dst_dev_event and dst_ifdown
> > and move that test down to the individual ifdown functions.
> 
> Yes, IPv6 needs "split device" semantics
> (for per-device statistics such as Ip6InDelivers etc),
> and I like later solution.

Ok.  I never read whether ipv6, like ipv4, is specified to support
a model of host based ownership of addresses.  Does anyone know?
