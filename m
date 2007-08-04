From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage.
Date: Sat, 4 Aug 2007 21:03:44 +0400
Message-ID: <20070804170344.GA18292@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <1a297b360708022204u4fc7603pb6baebe2bdf28618@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Manu Abraham <abraham.manu@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1a297b360708022204u4fc7603pb6baebe2bdf28618@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 03, 2007 at 09:04:51AM +0400, Manu Abraham (abraham.manu@gmail.com) wrote:
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

LDPC codes require to solve N order matrix over finite field - exactly
the reason I do not want to use Reed-Solomon codes even with optimized
non-Vandermonde matrix. I will investigate LDPC further though.
Turbo codes are like flow cipher compared to RS codes being block
ciphers. Transport media is reliable in data storages, otherwise they
would not even exist.

-- 
	Evgeniy Polyakov
