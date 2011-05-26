From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] net/core/filter.c: Fix build error
Date: Thu, 26 May 2011 21:12:56 +0200
Message-ID: <20110526191256.GA4553@elte.hu>
References: <efa062542c692c3f7743bf2d97b5987ab989e27e.1305999731.git.joe@perches.com>
 <20110526123153.GA16002@elte.hu>
 <1306423866.16087.10.camel@Joe-Laptop>
 <20110526.143843.205897228685761536.davem@davemloft.net>
 <20110526190939.GC3476@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, greearb@candelatech.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	arnd@arndb.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110526190939.GC3476@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> So no, i don't think your patch is the real solution. [...]

s/real/complete

Note, your patch solves a real problem: the ratelimited WARN_ON()s 
should not be in the generic bug.h header, that's just broken.

I just don't think this is the only problem: the other problem was 
what hid the bug in the first place, the spurious ratelimit.h 
inclusion via net.h.

Thanks,

	Ingo
