From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Tue, 22 Sep 2015 13:03:18 -0700
Message-ID: <CA+55aFzvp5gGS9jVA2O=vVM3Fd=VpCEfaqw8UKoU_Wk-ZkOgOg@mail.gmail.com>
References: <20150920.225521.1063980101511317898.davem@davemloft.net>
	<20150921060636.GA30807@gondor.apana.org.au>
	<20150920.231104.525285577747035896.davem@davemloft.net>
	<20150921133415.GA1740@gondor.apana.org.au>
	<20150921182022.GB13263@mtj.duckdns.org>
	<20150922033856.GA7851@gondor.apana.org.au>
	<20150922161056.GB9761@mtj.duckdns.org>
	<CA+55aFyvPLD5tNsuxFAA4GgOZpamULJe7R90dXf5qSC6aBYzTw@mail.gmail.com>
	<20150922185357.GD17659@mtj.duckdns.org>
	<CA+55aFy3k_NouhizkAkiZkuTYTqEKQZCnz8yOzrSH8o4+vjKUw@mail.gmail.com>
	<20150922195059.GF17659@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team@fb.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150922195059.GF17659@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 22, 2015 at 12:50 PM, Tejun Heo <tj@kernel.org> wrote:
>
> Hmmm?  We're doing that.  PPRO_FENCE makes both acquire and release
> use smp_mb().

Oh, right you are. I just grepped for rmb, and missed it because as
you say, it's a full mb.

The PPRO_FENCE_BUG thing is rather questionable. I'm not sure it's
even documented, but I can't find the official PPro errata now. I
think I discussed it with Andy Glew back when Intel was starting to
document the memory ordering rules.

I'd be willing to get rid of it. It was apparently just an early
stepping or two.

Anybody with better google-fu than me who can find the official Intel
PPro errata?

                 Linus
