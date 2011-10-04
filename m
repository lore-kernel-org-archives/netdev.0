From: Serge Belyshev <belyshev@depni.sinp.msu.ru>
Subject: Re: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Wed, 05 Oct 2011 00:12:06 +0400
Message-ID: <87zkhg1ppl.fsf@depni.sinp.msu.ru>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
	<alpine.DEB.2.00.1110041358500.12199@router.home>
	<1317757118.3580.24.camel@Joe-Laptop>
	<alpine.DEB.2.00.1110041442020.15871@router.home>
	<874nzo35bu.fsf@depni.sinp.msu.ru>
	<alpine.DEB.2.00.1110041501130.16183@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, starlight@binnacle.cx,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Christoph Lameter <cl@gentwo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1110041501130.16183@router.home> (Christoph
	Lameter's message of "Tue, 4 Oct 2011 15:03:38 -0500 (CDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


BFS FAQ writes:

> NUMA aware?
>
> It is NOT NUMA aware in the sense that it does any fancy shit on NUMA, but
> it will work on NUMA hardware just fine. Only the really big NUMA hardware
> is likely to suffer in performance, and this is theoretically only, since
> no one has that sort of hardware to prove it to me, but it seems almost
> certain. 
This part of FAQ entry was written before 0.300, (i.e. more than 2 years ago)


> v0.300 onwards have NUMA enhancements.
And this was added after. =)

As of now, BFS scheduling is NUMA-aware. (see resched_best_mask())
