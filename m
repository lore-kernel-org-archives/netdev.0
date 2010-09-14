From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 18492] New: kernel softirq warning on boot
Date: Tue, 14 Sep 2010 14:11:03 -0700 (PDT)
Message-ID: <20100914.141103.123996613.davem@davemloft.net>
References: <20100914120738.6a658f69.akpm@linux-foundation.org>
	<AANLkTinE50xFx9nShGBeOf483G2FhogO-BCj=dfHBZS7@mail.gmail.com>
	<20100914135730.8af6bc76.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hramrach@centrum.cz, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, herbert@gondor.hengli.com.au
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36534
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754248Ab0INVKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 17:10:45 -0400
In-Reply-To: <20100914135730.8af6bc76.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 14 Sep 2010 13:57:30 -0700

> On Tue, 14 Sep 2010 22:45:19 +0200
> Michal Suchanek <hramrach@centrum.cz> wrote:
> 
>> > rcu_read_unlock_bh() in netpoll_rx(), added by "netpoll: Fix RCU
>> > usage".
>> 
>> Do you mean de85d99eb7b595f6751550184b94c1e2f74a828b?
> 
> yup.
> 
>> I am not sure reverting just that would work, nor that the kernel
>> around that point is in shape for trying on a system I would want to
>> still use. It's way back in history for a kernel which is just to be
>> released.
> 
> No, we wouldn't want to revert it - it fixes stuff.
> 
> It could be that we just don't need the _bh locking, if local irqs are
> reliably disabled.  But I didn't really look.

I'll take a closer look at this if Herbert doesn't beat me to it.
