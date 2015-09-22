From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Tue, 22 Sep 2015 15:50:59 -0400
Message-ID: <20150922195059.GF17659@mtj.duckdns.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>, tom@herbertland.com,
	kafai@fb.com, kernel-team@fb.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFy3k_NouhizkAkiZkuTYTqEKQZCnz8yOzrSH8o4+vjKUw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Sep 22, 2015 at 12:28:45PM -0700, Linus Torvalds wrote:
> Both acquire and smp_rmb() are equally free on x86.

Was this always like this?  Ah, okay, from 2007.  Was thinking it's
still doing an actual rmb.  Talk about being confused.

> It appears that we don't do the X86_PPRO_FENCE bug handling for
> acquire, but I guess we should.

Hmmm?  We're doing that.  PPRO_FENCE makes both acquire and release
use smp_mb().

Thanks.

-- 
tejun
