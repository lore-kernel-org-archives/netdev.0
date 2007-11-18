From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a
 cond_resched()
Date: Sat, 17 Nov 2007 16:27:43 -0800 (PST)
Message-ID: <20071117.162743.93964350.davem@davemloft.net>
References: <p73fxz5auk5.fsf@bingen.suse.de>
	<473F1589.9080101@cosmosbay.com>
	<20071117214640.GA16314@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37886
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751237AbXKRA1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 19:27:44 -0500
In-Reply-To: <20071117214640.GA16314@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Sat, 17 Nov 2007 22:46:40 +0100

> > The 25.000.000 ns and 88.000.000 ns numbers where on an empty table, but 
> > large (16 MB of memory)
> 
> This would mean that cond_resched() needs ~4x as much time as checking
> an empty bucket. I find that somewhat hard to believe.

Based upon Arjan's analysis of the stall created by the
cond_resched() assembler, this doesn't surprise me.

I also don't believe Eric would make up such numbers or
measure them carelessly and then present them as fact.
