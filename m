From: jamal <hadi@cyberus.ca>
Subject: Re: [TRIVIAL] Fix recent bug in fib_semantics.c
Date: 18 Sep 2004 16:31:03 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1095539462.1043.1.camel@jzny.localdomain>
References: <9e47339104091717215e9be08b@mail.gmail.com>
	 <E1C8T4t-0006ug-00@gondolin.me.apana.org.au>
	 <9e473391040917183726113e91@mail.gmail.com>
	 <20040918041627.GA12356@gondor.apana.org.au>
	 <20040917233108.561c88d6.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jonsmirl@gmail.com,
	david@gibson.dropbear.id.au, akpm@osdl.org,
	trivial@rustcorp.com.au, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269622AbUIRUbM@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040917233108.561c88d6.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

On Sat, 2004-09-18 at 02:31, David S. Miller wrote:
> On Sat, 18 Sep 2004 14:16:28 +1000

> So if you rmmod() a device before any routes are ever
> created in ipv4, this triggers.  I didn't think this
> was possible, but it is.

May have been exposed by LLTX. When i turned off LLTX on e1000
before seeing your fix, the oops disapeared.

cheers,
jamal
