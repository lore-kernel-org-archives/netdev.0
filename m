From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9 failed assertion in tcp_timer.c
Date: Thu, 21 Oct 2004 22:53:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021225332.7f6bcfaf.davem@davemloft.net>
References: <20041019215054.GA17565@linuxace.com>
	<E1CK3Az-0004P2-00@gondolin.me.apana.org.au>
	<20041020164748.GA20905@linuxace.com>
	<20041020212651.GA8534@gondor.apana.org.au>
	<20041020225536.GA22179@linuxace.com>
	<20041021130339.GA19345@gondor.apana.org.au>
	<20041021165224.GA25399@linuxace.com>
	<20041021215743.GA23062@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel@linuxace.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041021215743.GA23062@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Oct 2004 07:57:43 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Dave, we need to use the skb's MSS in trim_head as otherwise the
> counters will be screwed up.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Excellent catch.  Patch applied, thanks Herbert.
