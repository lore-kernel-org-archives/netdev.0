From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] tcp: fix crash in tcp_xmit_retransmit_queue
Date: Mon, 19 Jul 2010 12:55:00 -0700 (PDT)
Message-ID: <20100719.125500.257479409.davem@davemloft.net>
References: <1279548555.2553.51.camel@edumazet-laptop>
	<alpine.DEB.2.00.1007192013010.30181@melkinpaasi.cs.helsinki.fi>
	<1279561148.2553.150.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, lennart.schulte@nets.rwth-aachen.de,
	tj@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, henning.fehrmann@aei.mpg.de,
	carsten.aulbert@aei.mpg.de
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279561148.2553.150.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Jul 2010 19:39:08 +0200

> Do you know in what exact circumstance the bug triggers ?
> 
> It's hard to believe thousand of machines on the Internet never hit
> it :(
> 
> Maybe another problem in congestion control ?

This is something to investigate, but the conditions under which
tcp_fastretrans_alert() (the main invoker of tcp_xmit_retransmit_queue())
does it's thing are complicated enough that I'm going to add this fix
for the time being and push it out to stable too.

Thanks everyone.
