From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Linux 3.1-rc9
Date: Wed, 2 Nov 2011 11:10:27 -0700
Message-ID: <CA+55aFwoWJMhdE7rG5LBy6vE=4BxYK1x=yoNeFB=5aKF8TZb7A@mail.gmail.com>
References: <1318874090.4172.84.camel@twins> <CA+55aFwCBy=4YK6amE=H-BYu9-boj4Po2Zkgf4V261mCx0DC4A@mail.gmail.com>
 <1318879396.4172.92.camel@twins> <alpine.LFD.2.02.1110172237030.3240@ionos>
 <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins>
 <20111018182046.GF1309@hostway.ca> <alpine.LFD.2.02.1110182146440.3240@ionos>
 <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca>
 <20111031173246.GA10614@hostway.ca> <alpine.LFD.2.02.1111021725550.2829@ionos>
 <1320254854.2292.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CA+55aFxKtA0XXtiKgKC5qHmFuTv2=TbuMEczkegJKY4Uy00a-g@mail.gmail.com>
 <1320256412.2292.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CA+55aFzYHJcGEmuj900G60DECBvdWDWNC09N393PWutsFUL-oQ@mail.gmail.com> <1320257141.2292.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Thomas Gleixner <tglx@linutronix.de>, Simon Kirby <sim@hostway.ca>,
	David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320257141.2292.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 2, 2011 at 11:05 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Yes, but only when tproxy is used, and in some obscure error
> conditions... Probably nobody ever hit them or complained.

Yes, I'm not disputing that. However, it does show how incredibly
fragile that code is.

May I suggest renaming those "clone_sk()" kinds of functions
"clone_sk_lock()" or something? So that you *see* that it's locked as
it is cloned. That might have made the bug not happen in the first
place..

Of course, maybe it's obvious to most net people - just not me looking
at the code - that the new socket ended up being locked at allocation.
But considering the bug happened twice, that "obvious" part is clearly
debatable..

                          Linus
