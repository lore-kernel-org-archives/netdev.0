From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9 failed assertion in tcp_timer.c
Date: Mon, 25 Oct 2004 13:25:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025132545.3d8d1890.davem@davemloft.net>
References: <E1CK3Az-0004P2-00@gondolin.me.apana.org.au>
	<20041020164748.GA20905@linuxace.com>
	<20041020212651.GA8534@gondor.apana.org.au>
	<20041020225536.GA22179@linuxace.com>
	<20041021130339.GA19345@gondor.apana.org.au>
	<20041021165224.GA25399@linuxace.com>
	<20041021215743.GA23062@gondor.apana.org.au>
	<20041022185435.GA30709@linuxace.com>
	<20041022215040.GA13309@gondor.apana.org.au>
	<20041022232403.GA14618@gondor.apana.org.au>
	<20041025195815.GA28640@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Phil Oester <kernel@linuxace.com>
In-Reply-To: <20041025195815.GA28640@linuxace.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Oct 2004 12:58:15 -0700
Phil Oester <kernel@linuxace.com> wrote:

> > Later on we can "fix" this by remembering where the original TSO
> > packet started from, perhaps in skb->h or somewhere.  Dave, is this
> > worth it?
> 
> Looks like your most recent 2 patches did the trick.  Uptime on the
> test box is over 4 hours, whereas before I could count on a panic
> within about an hour.  I'll continue running 2.6.9 + your patches
> and let you know if this changes...

Thanks for testing Phil.

Herbert I'll ponder over this patch today.
