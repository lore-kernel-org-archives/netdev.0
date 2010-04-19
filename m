From: Ingo Molnar <mingo@elte.hu>
Subject: Re: tip: origin tree build failure, [patch] fix isdn/gigaset build
 failure
Date: Mon, 19 Apr 2010 21:54:05 +0200
Message-ID: <20100419195405.GA21803@elte.hu>
References: <20100419.003857.260094283.davem@davemloft.net>
 <20100419172731.GA4358@elte.hu>
 <20100419.103304.35342954.davem@davemloft.net>
 <20100419180520.GA9244@elte.hu>
 <alpine.LFD.2.00.1004191112550.14500@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004191200050.14500@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tilman@imap.cc,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1004191200050.14500@i5.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, 19 Apr 2010, Linus Torvalds wrote:
> > 
> > Maybe add the #include <linux/sched.h> into gigaset.h, instead of 
> > common.c?
> 
> This compiled for me, although the only thing I tried was just turning all 
> the gigaset options to 'y'. Maybe some other config doesn't work. So I 
> committed it as likely to fix things.

I'll check it tomorrow - but i'd expect it to be enough, plus the all-yes 
thing is that matters most in practice in any case.

Thanks,

	Ingo
