From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Fri, 18 Jul 2008 11:05:06 +0200
Message-ID: <20080718090506.GO6875@elte.hu>
References: <20080717214222.GA29449@elte.hu> <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com> <20080717.190315.186892939.davem@davemloft.net> <19f34abd0807180003m7bdf832g141777751d7ea563@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penberg@cs.helsinki.fi, rjw@sisk.pl
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756187AbYGRJFo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <19f34abd0807180003m7bdf832g141777751d7ea563@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Vegard Nossum <vegard.nossum@gmail.com> wrote:

> But.. it could also be some random corruption coming from elsewhere. 
> Maybe even bad RAM (it's just a single bit anyway). But that's less 
> likely.

ok, i looked at the logs once more and while i thought that it occured 
twice it only occured once:

  Jul 17 20:22:14 europe kernel: BUG skbuff_head_cache: Poison overwritten

... this would explain why my attempts to bisect and reproduce it 
failed. I got too excited about it being seemingly reproducible and 
possibly bisectable (memory corruption bugs rarely are). My overnight 
reboot-the-same-kernel tests didnt show anything either.

It's a known-reliable system with thousands of bootups:

 Jul 17 20:20:54 europe kernel: Linux version 2.6.26-tip (mingo@europe) 
 (gcc version 4.2.2) #3094 SMP Thu Jul 17 20:19:27 CEST 2008

... but a hw fluke is never out of question. (It wasnt a particularly 
hot day but the evening was unusually humid, maybe that made the 
difference.)

So lets close this for now, it's not a reproducible regression that we 
can act upon. I'll update this thread if anything new happens. 
Netconsole is reliable on this system in any case.

	Ingo
