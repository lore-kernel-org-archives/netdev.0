From: Christoph Lameter <cl@gentwo.org>
Subject: Re: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Tue, 4 Oct 2011 15:03:38 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1110041501130.16183@router.home>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx> <alpine.DEB.2.00.1110041358500.12199@router.home> <1317757118.3580.24.camel@Joe-Laptop> <alpine.DEB.2.00.1110041442020.15871@router.home> <874nzo35bu.fsf@depni.sinp.msu.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>, starlight@binnacle.cx,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Serge Belyshev <belyshev@depni.sinp.msu.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.prem.mail.ac4.yahoo.com ([76.13.13.93]:20816 "HELO
	smtp110.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933524Ab1JDUDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 16:03:43 -0400
In-Reply-To: <874nzo35bu.fsf@depni.sinp.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Oct 2011, Serge Belyshev wrote:

>
> Christoph Lameter <cl@gentwo.org> writes:
> > No. BFS has no NUMA support.
>
> BFS has NUMA support since v0.300, 1st oct. 2009.

>From the BFS FAQ (lack of NUMA support causes additional memory latencies,
the high end business server these days have NUMA):

NUMA aware?

It is NOT NUMA aware in the sense that it does any fancy shit on NUMA, but
it will work on NUMA hardware just fine. Only the really big NUMA hardware
is likely to suffer in performance, and this is theoretically only, since
no one has that sort of hardware to prove it to me, but it seems almost
certain. v0.300 onwards have NUMA enhancements.
