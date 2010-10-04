From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH] tms380tr: fix long delays in initialization
Date: Tue, 5 Oct 2010 00:15:17 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1010050012380.5418@math.ut.ee>
References: <alpine.SOC.1.00.1010032228450.28867@math.ut.ee> <20101003.200109.226763463.davem@davemloft.net> <alpine.SOC.1.00.1010041135060.12325@math.ut.ee> <20101004.094254.35052481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:47722 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932529Ab0JDVPT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 17:15:19 -0400
In-Reply-To: <20101004.094254.35052481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> tms380tr_init_adapter() gets called from tms380tr_chk_irq() which is
> invoked from the interrupt handler.

Oops, yes, sorry for repeatedly not noticing it even when I was 
explicitly searching for it :(

What is the general course from here? Defer the long reset to a work 
queue, or some other kind of background task?

-- 
Meelis Roos (mroos@linux.ee)
