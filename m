From: David Miller <davem@davemloft.net>
Subject: Re: [patch] locking, percpu counters: introduce separate lock
 classes
Date: Mon, 29 Dec 2008 23:04:38 -0800 (PST)
Message-ID: <20081229.230438.90548187.davem@davemloft.net>
References: <20081230060536.GG11037@elte.hu>
	<20081229.223945.149941966.davem@davemloft.net>
	<20081230065650.GD30975@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, a.p.zijlstra@chello.nl,
	emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53171
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751310AbYL3HEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 02:04:36 -0500
In-Reply-To: <20081230065650.GD30975@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 30 Dec 2008 07:56:50 +0100

> 
> * David Miller <davem@davemloft.net> wrote:
> 
> > From: Ingo Molnar <mingo@elte.hu>
> > Date: Tue, 30 Dec 2008 07:05:36 +0100
> > 
> > > One small nit: could you please add the Reported-by line for Jeff Kirscher 
> > > who reported the problem originally:
> > > 
> > >  Reported-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > 
> > I'll make sure to add that to the commit message after
> > you successfully test Herbert's patch.
> > 
> > Thanks.
> 
> early indications are good: after about 15 random bootup tests the lockdep 
> warning has not triggered. (it would trigger on every 2nd kernel before 
> that - there's a 66% chance for lockdep to be enabled in my randconfig 
> tests)

Sounds good.  I'll toss this into my net-2.6 tree, with Jeff's
reported-by and your Tested-by, and send this off to Linus
tonight.

Thanks everyone.
