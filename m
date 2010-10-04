From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH] ibmtr: fix tr%d in dmesg
Date: Tue, 5 Oct 2010 00:12:33 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1010042301100.5418@math.ut.ee>
References: <alpine.SOC.1.00.1010022056000.27121@math.ut.ee> <20101003.205632.104074109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.it.da.ut.ee ([193.40.5.66]:54181 "EHLO smtp1.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756523Ab0JDVMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 17:12:35 -0400
In-Reply-To: <20101003.205632.104074109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Instead, the more correct way to fit this is to use dev_info(),
> dev_err(), and friends.  It will both print the correct stuff,
> and also document the probing path messages that occur before
> the net device is registered.

OK, fair enough.

I remember trying dev_info first and getting null from it. Retried, got
 (null): ISA P&P 16/4 Adapter/A (short) | 16/4 ISA-16 Adapter found

So it seems dev_info does not know about 16-bit pcmcia devices or 
buses... dev_driver_string() finds neither dev->name, dev->bus->name nor 
dev->class->name. Will dig into this some other day.

-- 
Meelis Roos (mroos@linux.ee)
