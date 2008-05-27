From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [PLEASE REVERT] "Add a WARN_ON_ONCE" at
 net/sched/sch_generic.c:
Date: Tue, 27 May 2008 21:34:24 +0900
Message-ID: <20080527213424.125e15dc.komurojun-mbn@nifty.com>
References: <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
	<20080525.051032.186144643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg500.nifty.com ([202.248.238.80]:44134 "EHLO
	userg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753034AbYE0Min (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 08:38:43 -0400
In-Reply-To: <20080525.051032.186144643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 May 2008 05:10:32 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> > Please revert the patch "Add a WARN_ON_ONCE() to
> >  the transmit timeout function".
> > 
> > The transmit timeout sometimes happens on normal operation.
> > This message annoys me.
> 
> Sometimes, but not often.
> 
> Most of the time it does indicate a bug and we absolutely cannot
> diagnose it without the backtrace.

I think the transmit timeout indicates 
that the cable is not connected or the irq is conflict.


Best Regards
Komuro

