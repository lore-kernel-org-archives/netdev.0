From: Dave Dillow <dave@thedillows.org>
Subject: Re: Distributed storage.
Date: Fri, 03 Aug 2007 22:51:08 -0400
Message-ID: <1186195868.16431.5.camel@obelisk.thedillows.org>
References: <20070731171347.GA14267@2ka.mipt.ru>
	 <1a297b360708022204u4fc7603pb6baebe2bdf28618@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Manu Abraham <abraham.manu@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1a297b360708022204u4fc7603pb6baebe2bdf28618@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-03 at 09:04 +0400, Manu Abraham wrote:
> On 7/31/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > TODO list currently includes following main items:
> >     * redundancy algorithm (drop me a request of your own, but it is highly
> >         unlikley that Reed-Solomon based will ever be used - it is too slow
> >         for distributed RAID, I consider WEAVER codes)
> 
> 
> LDPC codes[1][2] have been replacing Turbo code[3] with regards to
> communication links and we have been seeing that transition. (maybe
> helpful, came to mind seeing the mention of Turbo code) Don't know how
> weaver compares to LDPC, though found some comparisons [4][5] But
> looking at fault tolerance figures, i guess Weaver is much better.
> 
> [1] http://www.ldpc-codes.com/
> [2] http://portal.acm.org/citation.cfm?id=1240497
> [3] http://en.wikipedia.org/wiki/Turbo_code
> [4] http://domino.research.ibm.com/library/cyberdig.nsf/papers/BD559022A190D41C85257212006CEC11/$File/rj10391.pdf
> [5] http://hplabs.hp.com/personal/Jay_Wylie/publications/wylie_dsn2007.pdf

Searching Google for Dr. Plank's work at the University of TN turns up
some analysis of using LDPC codes in storage systems.

http://www.google.com/search?hl=en&q=plank+ldpc&btnG=Google+Search

Patents are an issue to watch out for around the use of Tornado/Raptor
codes. I've not researched it, but I believe there be dragons there.
