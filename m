From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : change layout of ehash table
Date: Fri, 9 Feb 2007 10:06:24 +0100
Message-ID: <200702091006.24242.dada1@cosmosbay.com>
References: <200702071159.34935.dada1@cosmosbay.com> <p73zm7n1ygk.fsf@bingen.suse.de> <20070209.004019.75431263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, linux@horizon.com, akepner@sgi.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:48419 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946237AbXBIJG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 04:06:29 -0500
In-Reply-To: <20070209.004019.75431263.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 09:40, David Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: 09 Feb 2007 10:18:03 +0100
>
> > David Miller <davem@davemloft.net> writes:
> > > I've applied this, but I _REALLY_ don't like the new multiply
> > > instructions that are used now in the hash indexing paths when
> > > CONFIG_SMP is set.
> > >
> > > I think that's a higher cost than the memory waste.
> >
> > You're serious? multiply on a modern CPU is _much_ cheaper than a cache
> > miss e.g. a K8 can do a arbitary 64bit multiplication in 3-7 cycles.
> > Any cache miss will be in the three to four digits at least.
>
> I'm not thinking of modern CPUs, I'm think of the little
> guys :-)

Yes, but a decent C compiler for such targets should not use a multiply 
instruction to perform a (idx * 12) operation... :)
