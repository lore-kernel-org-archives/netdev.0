From: "Manu Abraham" <abraham.manu@gmail.com>
Subject: Re: Distributed storage.
Date: Sat, 4 Aug 2007 07:44:48 +0400
Message-ID: <1a297b360708032044q4e2fa558s576478e3e75308bf@mail.gmail.com>
References: <20070731171347.GA14267@2ka.mipt.ru>
	 <1a297b360708022204u4fc7603pb6baebe2bdf28618@mail.gmail.com>
	 <1186195868.16431.5.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: "Dave Dillow" <dave@thedillows.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1186195868.16431.5.camel@obelisk.thedillows.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/4/07, Dave Dillow <dave@thedillows.org> wrote:
> On Fri, 2007-08-03 at 09:04 +0400, Manu Abraham wrote:
> > On 7/31/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >
> > > TODO list currently includes following main items:
> > >     * redundancy algorithm (drop me a request of your own, but it is highly
> > >         unlikley that Reed-Solomon based will ever be used - it is too slow
> > >         for distributed RAID, I consider WEAVER codes)
> >
> >
> > LDPC codes[1][2] have been replacing Turbo code[3] with regards to
> > communication links and we have been seeing that transition. (maybe
> > helpful, came to mind seeing the mention of Turbo code) Don't know how
> > weaver compares to LDPC, though found some comparisons [4][5] But
> > looking at fault tolerance figures, i guess Weaver is much better.
> >
> > [1] http://www.ldpc-codes.com/
> > [2] http://portal.acm.org/citation.cfm?id=1240497
> > [3] http://en.wikipedia.org/wiki/Turbo_code
> > [4] http://domino.research.ibm.com/library/cyberdig.nsf/papers/BD559022A190D41C85257212006CEC11/$File/rj10391.pdf
> > [5] http://hplabs.hp.com/personal/Jay_Wylie/publications/wylie_dsn2007.pdf
>
> Searching Google for Dr. Plank's work at the University of TN turns up
> some analysis of using LDPC codes in storage systems.
>
> http://www.google.com/search?hl=en&q=plank+ldpc&btnG=Google+Search
>
> Patents are an issue to watch out for around the use of Tornado/Raptor
> codes. I've not researched it, but I believe there be dragons there.
>

We don't use the code in the driver straight away [2] (in the case
that i mentioned), since that happens in the hardware (demodulator
chip) [1], but we have an interface for selecting the code-rate [2]
(LDPC/BCH) for DVB-S2 and the new papers for DVB-T2 looks geared that
the base decision is to use LDPC.

Though i now see a patent application for it [3]. Not sure whether it
is a registered patent, i am under an agreement of Non-Disclosure with
STM. Will ask the relevant person there, whether they have it
registered. (Most probably they may have it registered).

There are a few people from STM on LK, if not they can possibly
confirm whether the patent is regsitered or not.

[1] http://www2.dac.com/data2/42nd/42acceptedpapers.nsf/0c4c09c6ffa905c487256b7b007afb72/998f93e4b29e99fa87256fc400714617/$FILE/33_1.pdf

[2] http://linuxtv.org/hg/~manu/stb0899-c5/file/760cb230695c/linux/include/linux/dvb/frontend.h

[3] http://www.freepatentsonline.com/20060206779.html
http://www.freepatentsonline.com/20060206778.html
