From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Regression caused by commit "netfilter: iptables: lock free
 counters"
Date: Sun, 5 Apr 2009 13:36:46 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904051328030.7501@fbirervta.pbzchgretzou.qr>
References: <20090329234702.4988017f@desktop.r000n.info> <8763hja8cy.fsf@newton.gmurray.org.uk> <20090405.012237.198610462.davem@davemloft.net> <49D88162.5040809@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, graham@gmurray.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49D88162.5040809@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday 2009-04-05 12:01, Eric Dumazet wrote:
>
>This could probably be solved using a single "table" containing
>rules only, that could be shared for every cpus. Only counters
>should be percpu. This should save a lot of ram, over previous
>situation (2.6.29 or current one)

Why would counters stay separate?

I recognize all of this table copying is related to do NUMA
optimizations, and I think I heard cache bouncing too somewhere else.

[ http://marc.info/?l=netfilter-devel&m=119903624211253&w=2 ]
