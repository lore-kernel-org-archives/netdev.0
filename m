From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Sat, 18 Sep 2004 09:16:11 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918.091611.13449142.yoshfuji@linux-ipv6.org>
References: <20040917153536.6acec52e.davem@davemloft.net>
	<20040918.085003.77842779.yoshfuji@linux-ipv6.org>
	<20040917170607.2e96b58a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040917170607.2e96b58a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040917170607.2e96b58a.davem@davemloft.net> (at Fri, 17 Sep 2004 17:06:07 -0700), "David S. Miller" <davem@davemloft.net> says:

> >  2. David's one
> >     - maintenancability will be improved
> >     - maintains exported symbols for binary-only modules.
> >     - more function call and more stack usage.
> 
> Compiler is smarter than you think :-)
> 
> The whole stack frame is eliminated, because gcc
> optimizes it away using tail-call optimizations.

Okay, thank you for explanation.
I'm not sure (and have some doubt) on i386,
but I am now smarter than before. :-)

--yoshfuji
