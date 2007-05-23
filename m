From: Ingo Molnar <mingo@elte.hu>
Subject: Re: bad networking related lag in v2.6.22-rc2
Date: Wed, 23 May 2007 13:40:21 +0200
Message-ID: <20070523114021.GA21880@elte.hu>
References: <20070517174533.GA538@elte.hu> <200705221147.56571.kernel@prachanda.hub> <20070522062233.GA20002@elte.hu> <200705231110.44526.kernel@prachanda.hub> <20070523063052.GB26814@elte.hu> <46541DC4.4090501@trash.net> <20070523112559.GA24604@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Anant Nitya <kernel@prachanda.info>,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764612AbXEWLmS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070523112559.GA24604@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> [NET_SCHED]: Fix qdisc_restart return value when dequeue is empty
> 
> My previous patch that changed the return value of qdisc_restart 
> incorrectly made the case where dequeue returns empty continue 
> processing packets.
> 
> This patch is based on diagnosis and fix by Patrick McHardy.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

also:

  Reported-and-debugged-by: Anant Nitya <kernel@prachanda.info>

...

i gave your patch a quick test-boot and networking still works fine.

	Ingo
