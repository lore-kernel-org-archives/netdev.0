From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tms380tr: fix long delays in initialization
Date: Mon, 04 Oct 2010 14:33:55 -0700 (PDT)
Message-ID: <20101004.143355.02257623.davem@davemloft.net>
References: <alpine.SOC.1.00.1010041135060.12325@math.ut.ee>
	<20101004.094254.35052481.davem@davemloft.net>
	<alpine.SOC.1.00.1010050012380.5418@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807Ab0JDVde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 17:33:34 -0400
In-Reply-To: <alpine.SOC.1.00.1010050012380.5418@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Tue, 5 Oct 2010 00:15:17 +0300 (EEST)

>> tms380tr_init_adapter() gets called from tms380tr_chk_irq() which is
>> invoked from the interrupt handler.
> 
> Oops, yes, sorry for repeatedly not noticing it even when I was 
> explicitly searching for it :(
> 
> What is the general course from here? Defer the long reset to a work 
> queue, or some other kind of background task?

Yes, very likely a workqueue is the best course of action.
