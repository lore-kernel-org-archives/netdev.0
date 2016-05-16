From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [v4.6-rc7-183-g1410b74e4061]
Date: Mon, 16 May 2016 19:57:35 +0200
Message-ID: <20160516175735.GS3193@twins.programming.kicks-ass.net>
References: <CA+icZUXF9DkymNNGwP8zzmKY9PRAPGFZ+7p9En1xy80FcX_RRw@mail.gmail.com>
 <20160516105045.GA19189@gmail.com>
 <CA+icZUUJed6KqxhPKyrr_ACCfnp09T+R5S0J8-Bf6+1SJZvtoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+icZUUJed6KqxhPKyrr_ACCfnp09T+R5S0J8-Bf6+1SJZvtoQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2016 at 07:42:35PM +0200, Sedat Dilek wrote:

> Unfortunately, I could not reproduce this again with none of my 183-kernels.
> When I first hit a "chain_key collision" issue, it was hard to redproduce, so.
> Any idea, how I can "force" this?

Nope; I wish I knew, that'd be so much easier to work with :/

I'm hoping someone will report a reproducer, even something that
triggers once every 5-10 runs would be awesome.

In any case, like I've explained before, nothing regressed as such, we
only added this new warning under DEBUG_LOCKDEP because we want to
better understand the condition that triggers it.

If it bothers you, just turn off DEBUG_LOCKDEP and know that your kernel
is as reliable as it was before. OTOH, if you do keep it on, please
let me know if you can (semi) reliably trigger this, as I'd really like
to have a better understanding.
