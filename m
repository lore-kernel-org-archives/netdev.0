From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC IPROUTE 00/08]: Time cleanups + nano-second clock
 resolution support
Date: Tue, 13 Mar 2007 14:42:53 -0700
Message-ID: <20070313144253.430ef008@freekitty>
References: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37108 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933665AbXCMVm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 17:42:57 -0400
In-Reply-To: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun,  4 Mar 2007 20:14:53 +0100 (MET)
Patrick McHardy <kaber@trash.net> wrote:

> This patchset consists of four parts:
> 
> - minor TBF time conversion fix
> 
> - consolidation of time calculations: consolidate commonly used expressions
>   with the goal of making it easier to audit for integer overflows when
>   increasing the internally used clock resolution.
>  
> - support for detecting the clock resolution used by the kernel and converting
>   time values as necessary.
> 
> - finally, increase the internally used clock resolution to nano-seconds
> 
> These patches have been tested (well, TBF and HFSC) with both old kernels
> and patched kernels using nano-second resolution.
> 
> 
>  tc/m_estimator.c  |    4 +--
>  tc/m_police.c     |    2 -
>  tc/q_cbq.c        |   15 +++++++------
>  tc/q_hfsc.c       |   18 +++++++--------
>  tc/q_htb.c        |    4 +--
>  tc/q_netem.c      |   14 +++---------
>  tc/q_tbf.c        |   22 +++++++++----------
>  tc/tc_cbq.c       |    8 +++----
>  tc/tc_core.c      |   61 ++++++++++++++++++++++++++++++++++++++----------------
>  tc/tc_core.h      |   13 +++++++----
>  tc/tc_estimator.c |    2 -
>  tc/tc_red.c       |    2 -
>  tc/tc_util.c      |   40 ++++++++++++++++++++++-------------
>  tc/tc_util.h      |    7 +++---
>  14 files changed, 125 insertions(+), 87 deletions(-)
> 
> Patrick McHardy:
>       [IPROUTE]: tbf: fix latency printing
>       [IPROUTE]: Use tc_calc_xmittime() where appropriate
>       [IPROUTE]: Introduce tc_calc_xmitsize and use where appropriate
>       [IPROUTE]: Introduce TIME_UNITS_PER_SEC to represent internal clock resolution
>       [IPROUTE]: Replace "usec" by "time" in function names
>       [IPROUTE]: Add sprint_ticks() function and use in CBQ
>       [IPROUTE]: Handle different kernel clock resolutions
>       [IPROUTE]: Increase internal clock resolution to nsec

applied all

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
