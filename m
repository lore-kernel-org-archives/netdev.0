From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [v4.6-rc7-183-g1410b74e4061]
Date: Mon, 16 May 2016 12:50:45 +0200
Message-ID: <20160516105045.GA19189@gmail.com>
References: <CA+icZUXF9DkymNNGwP8zzmKY9PRAPGFZ+7p9En1xy80FcX_RRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+icZUXF9DkymNNGwP8zzmKY9PRAPGFZ+7p9En1xy80FcX_RRw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Sedat Dilek <sedat.dilek@gmail.com> wrote:

> Hi,
> 
> as Linux v4.6 is very near, I decided to write this bug report (only
> drunk one coffee).
> 
> First, I am not absolutely sure if this is a real issue as...
> #1: This is only a (lockdep) warning.
> #2: I have not a "vanilla" Linux v4.6-rc7+ here (see P.S. and attached patch)

Having such a kernel base is certainly not helpful to the quality of your report, 
please try to reproduce under the vanilla kernel.

> For a more helpful feedback I should test a...
> #1: vanilla v4.6-rc7-183-g1410b74e4061

I'd suggest v4.6 plus this debug patch from Peter:

  https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1142352.html

... to see whether something fishy is going on.

Thanks,

	Ingo
