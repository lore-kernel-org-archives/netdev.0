From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] net: irda: pxaficp_ir: use sched_clock() for
 time management
Date: Mon, 21 Sep 2015 16:12:35 -0700 (PDT)
Message-ID: <20150921.161235.605756522215336833.davem@davemloft.net>
References: <87eghyso6u.fsf@belgarion.home>
	<20150917.145106.1238429841434804906.davem@davemloft.net>
	<87si6br8ev.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, petr.cvek@tul.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87si6br8ev.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Fri, 18 Sep 2015 18:36:56 +0200

> Which brings me to wonder which is the more correct :
>  (a) replace to reproduce the same calculation
>      Previously mtt was compared to a difference of 76ns steps (as 307ns / 4 =
>      76ns):
>      while ((sched_clock() - si->last_clk) * 76 < mtt)
> 
>  (b) change the calculation assuming mtt is in microseconds :
>      while ((sched_clock() - si->last_clk) * 1000 < mtt)
> 
> I have no IRDA protocol knowledge so unless someone points me to the correct
> calculation I'll try my luck with (b).

"a" would be "safer" and less likely to break anything, although as
you say "b" might be more correct.
