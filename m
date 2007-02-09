From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : change layout of ehash table
Date: Fri, 09 Feb 2007 00:40:19 -0800 (PST)
Message-ID: <20070209.004019.75431263.davem@davemloft.net>
References: <200702071159.34935.dada1@cosmosbay.com>
	<20070208.145632.74749802.davem@davemloft.net>
	<p73zm7n1ygk.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, linux@horizon.com, akepner@sgi.com,
	netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50858
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1946201AbXBIIkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 03:40:21 -0500
In-Reply-To: <p73zm7n1ygk.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: 09 Feb 2007 10:18:03 +0100

> David Miller <davem@davemloft.net> writes:
> > 
> > I've applied this, but I _REALLY_ don't like the new multiply
> > instructions that are used now in the hash indexing paths when
> > CONFIG_SMP is set.
> > 
> > I think that's a higher cost than the memory waste.
> 
> You're serious? multiply on a modern CPU is _much_ cheaper than a cache miss
> e.g. a K8 can do a arbitary 64bit multiplication in 3-7 cycles.
> Any cache miss will be in the three to four digits at least.

I'm not thinking of modern CPUs, I'm think of the little
guys :-)
