From: Martin Devera <devik@cdi.cz>
Subject: Re: PSCHED_TDIFF_SAFE bug introduced in 2.4.19-pre5
Date: Sun, 12 May 2002 21:32:35 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0205122126530.12674-100000@luxik.cdi.cz>
References: <200205121635.UAA01437@mops.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200205121635.UAA01437@mops.inr.ac.ru>
List-Id: netdev.vger.kernel.org

> > even if tv1<tv2 which can be true when time wraps (which is true
> > at least with PSCHED_TIME_SOURCE == JIFFIES)
>
> No, psched_time_t cannot wrap for our life.

aarrrgh ... oh well I just found the PSCHED_WATCHER logic.
Then I'm sorry for my objection - I'll have to add
BUG_TRAP(!PSCHED_TLESS(tv1,tv2)) into my code ..

Thanks anyway,
devik
