From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Wed, 18 May 2005 15:28:15 +0200
Message-ID: <m1k6lw64uo.fsf@muc.de>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
	<m1sm0l5lwa.fsf@muc.de> <428AF378.5020109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <428AF378.5020109@cosmosbay.com> (Eric Dumazet's message of
 "Wed, 18 May 2005 09:49:12 +0200")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> writes:

> Related question, is pci_alloc_consistent() already NUMA aware ?

It depends on the architecture. On x86-64 it has been for a long time.
I believe IA64 also got it recently.

-Andi
