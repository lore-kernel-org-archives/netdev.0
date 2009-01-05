From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: update can-bcm for hrtimer hardirq callbacks
Date: Sun, 04 Jan 2009 17:32:00 -0800 (PST)
Message-ID: <20090104.173200.136616015.davem@davemloft.net>
References: <495E1B65.4070504@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peterz@infradead.org, mingo@elte.hu,
	tglx@linutronix.de
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49066
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751729AbZAEBb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:31:56 -0500
In-Reply-To: <495E1B65.4070504@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Fri, 02 Jan 2009 14:49:25 +0100

> Since commit ca109491f612aab5c8152207631c0444f63da97f the hrtimer callbacks are processed only in hardirq context.
> 
> This patch moves some functionality into tasklets to run in softirq context.
> 
> Additionally some duplicated code was removed in bcm_rx_thr_flush() and an avoidable memcpy was removed from bcm_rx_handler().
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied, thanks Oliver.

In the future, when referencing a commit SHA ID, please provide
the commit message header line as a secondary reference, like
this:

    Since commit ca109491f612aab5c8152207631c0444f63da97f ("hrtimer:
    removing all ur callback modes") the hrtimer callbacks are processed
    only in hardirq context.

Thanks.
