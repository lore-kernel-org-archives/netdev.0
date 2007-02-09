From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NET : change layout of ehash table
Date: Fri, 9 Feb 2007 09:57:24 +0100
Message-ID: <200702090957.25110.ak@suse.de>
References: <200702071159.34935.dada1@cosmosbay.com> <p73zm7n1ygk.fsf@bingen.suse.de> <20070209.004019.75431263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, linux@horizon.com, akepner@sgi.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58513 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946230AbXBII5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 03:57:36 -0500
In-Reply-To: <20070209.004019.75431263.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 09:40, David Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: 09 Feb 2007 10:18:03 +0100
> 
> > David Miller <davem@davemloft.net> writes:
> > > 
> > > I've applied this, but I _REALLY_ don't like the new multiply
> > > instructions that are used now in the hash indexing paths when
> > > CONFIG_SMP is set.
> > > 
> > > I think that's a higher cost than the memory waste.
> > 
> > You're serious? multiply on a modern CPU is _much_ cheaper than a cache miss
> > e.g. a K8 can do a arbitary 64bit multiplication in 3-7 cycles.
> > Any cache miss will be in the three to four digits at least.
> 
> I'm not thinking of modern CPUs, I'm think of the little
> guys :-)

Even for them it's true, although the ratios are smaller (unless you go back to 
m68000 or VAX days) 

-Andi
