From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9 failed assertion in tcp_timer.c
Date: Fri, 22 Oct 2004 15:12:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022151209.26b2d355.davem@davemloft.net>
References: <20041019215054.GA17565@linuxace.com>
	<E1CK3Az-0004P2-00@gondolin.me.apana.org.au>
	<20041020164748.GA20905@linuxace.com>
	<20041020212651.GA8534@gondor.apana.org.au>
	<20041020225536.GA22179@linuxace.com>
	<20041021130339.GA19345@gondor.apana.org.au>
	<20041021165224.GA25399@linuxace.com>
	<20041021215743.GA23062@gondor.apana.org.au>
	<20041022185435.GA30709@linuxace.com>
	<20041022215040.GA13309@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel@linuxace.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041022215040.GA13309@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 23 Oct 2004 07:50:40 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Oct 22, 2004 at 11:54:35AM -0700, Phil Oester wrote:
> > 
> > This patch gets it a bit further, but still panics (divide by 0?):
> 
> Oops, I forgot that this gets called on non-TSO packets as well.
> So we don't really know whether it went further or not :)
> 
> We should only set the TSO size if the packet was TSO to start with.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
