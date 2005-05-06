From: "David S. Miller" <davem@davemloft.net>
Subject: Re: oops in ip_rcv
Date: Thu, 5 May 2005 19:58:31 -0700
Message-ID: <20050505195831.6c747c32.davem@davemloft.net>
References: <20050505101542.GB7916@krispykreme>
	<E1DTeis-0005gu-00@gondolin.me.apana.org.au>
	<20050505130904.GA16593@krispykreme>
	<20050505112624.3ffd7f3d.davem@davemloft.net>
	<20050505213740.GB29526@gondor.apana.org.au>
	<20050505214453.GA29853@gondor.apana.org.au>
	<20050505150943.566280f0.davem@davemloft.net>
	<20050506010246.GA8255@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050506010246.GA8255@krispykreme>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 May 2005 11:02:46 +1000
Anton Blanchard <anton@samba.org> wrote:
 
> I start getting acenic irqs straight after the card is initialised:

Thanks, this needs to be fixed.  I bet some people would be very
unpleased to know that an inteface that hasn't been brought up
at least once will sit and receive broadcast frames :-/

Anyways, for now I'll put Herbert's ipv4 and ipv6 patches in.

Thanks a lot Anton :-)
