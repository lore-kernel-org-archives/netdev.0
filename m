From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Assertions when lowering tcp_tso_win_divisor
Date: Sat, 20 Nov 2004 19:25:30 -0800
Message-ID: <20041120192530.31d8b113.davem@davemloft.net>
References: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
	<E1CUAQ2-0002jT-00@gondolin.me.apana.org.au>
	<20041116163106.3b62a39a.davem@davemloft.net>
	<Pine.LNX.4.58.0411191755160.2567@w-sridhar.beaverton.ibm.com>
	<20041119223527.1f243d6e.davem@davemloft.net>
	<Pine.LNX.4.58.0411201503510.6242@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0411201503510.6242@w-sridhar.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 20 Nov 2004 15:19:54 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> I tried to do this myself by identifying the tso related patches
> that went in after 2.6.9 and just wanted to find out if i missed
> any other patches that may have fixed the tso related assertions.

At a minimum you missed the net/core/skbuff.c patch Herbert Xu
made to fix missing of copying around tso bits when copying/cloning
SKBs.
