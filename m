From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 24 Jul 2007 12:30:03 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com>
 <20070629150759.GC2771@ff.dom.local> <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
 <20070724080534.GC18740@elte.hu> <20070724094202.GA11610@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Marcin ??lusarz <marcin.slusarz@gmail.com>,
	Jarek Poplawski <jarkao2@o2.pl>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070724094202.GA11610@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 24 Jul 2007, Ingo Molnar wrote:
> 
> please try the patch below instead.

I'm hoping this is just a "let's see if the behavior changes" patch, not 
something that you think should be applied if it fixes something?

This patch looks like it is trying to paper over (rather than fix) some 
possible bug in the "->disable" logic. Makes sense as a "let's see if it's 
that" kind of thing, but not as a "let's fix it".

Or am I missing something?

		Linus
