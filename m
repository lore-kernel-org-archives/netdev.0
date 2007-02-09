From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NET : change layout of ehash table
Date: 09 Feb 2007 10:18:03 +0100
Message-ID: <p73zm7n1ygk.fsf@bingen.suse.de>
References: <20061219224726.GC4274@sortiz.org>
	<20070207.001226.63510892.davem@davemloft.net>
	<200702071159.34935.dada1@cosmosbay.com>
	<20070208.145632.74749802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, linux@horizon.com, akepner@sgi.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:38444 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946208AbXBIIRt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 03:17:49 -0500
In-Reply-To: <20070208.145632.74749802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> 
> I've applied this, but I _REALLY_ don't like the new multiply
> instructions that are used now in the hash indexing paths when
> CONFIG_SMP is set.
> 
> I think that's a higher cost than the memory waste.

You're serious? multiply on a modern CPU is _much_ cheaper than a cache miss
e.g. a K8 can do a arbitary 64bit multiplication in 3-7 cycles.
Any cache miss will be in the three to four digits at least.

-Andi
