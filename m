From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [lockdep warning] AOE / networking: aoenet_xmit:
	noop_qdisc.q.lock, INFO: inconsistent lock state at 0000000000000370
Date: Fri, 25 Jul 2008 09:26:24 +0200
Message-ID: <20080725072624.GA21824@elte.hu>
References: <20080721.134608.75595942.davem@davemloft.net> <20080725062009.GA6476@elte.hu> <20080724.232521.193699299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ecashin@coraid.com, axboe@suse.de, mike.miller@hp.com,
	a.p.zijlstra@chello.nl, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753694AbYGYH04@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080724.232521.193699299.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Fri, 25 Jul 2008 08:20:09 +0200
> 
> > not sure whether it got reported already, but -tip testing triggered 
> > this new ATA over Ethernet lockdep warning on latest -git:
> 
> Thanks for the report, does this fix it?

i've tested it and the warning went away - thanks David!

Tested-by: Ingo Molnar <mingo@elte.hu>

	Ingo
