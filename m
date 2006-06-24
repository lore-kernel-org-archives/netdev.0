From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [3/5] [NET]: Add software TSOv4
Date: Fri, 23 Jun 2006 17:28:12 -0700
Message-ID: <004201c69725$14123700$4110100a@pc.s2io.com>
References: <20060622.143206.111203586.davem@davemloft.net>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48548 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S932748AbWFXAtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 20:49:14 -0400
To: "'David Miller'" <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>
In-Reply-To: <20060622.143206.111203586.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neterion's Xframe adapter supports TSO over IPv6.

Ravi

-----Original Message-----
From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]On Behalf Of David Miller
Sent: Thursday, June 22, 2006 2:32 PM
To: yoshfuji@linux-ipv6.org
Cc: herbert@gondor.apana.org.au; netdev@vger.kernel.org
Subject: Re: [3/5] [NET]: Add software TSOv4


From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 23 Jun 2006 00:04:03 +0900 (JST)

> In article <20060622081400.GC22671@gondor.apana.org.au> (at Thu, 22 Jun
2006 18:14:00 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
>
> > [NET]: Add software TSOv4
> >
> > This patch adds the GSO implementation for IPv4 TCP.
> >
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> I'd appreciate if you code up IPv6 TCP as well. :-)

To my understanding doing IPV6 TCP TSO is a non-trivial task, even in
software.

The header editing is a lot more complicated because things like
routing and other extension headers can sit between IPV6 and TCP
header.

It is probably why IPV6 TSO hardware does not exist yet :)

Do not take this to mean I think it should not be implemented, I think
it should.
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

