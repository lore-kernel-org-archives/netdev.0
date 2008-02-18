From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 1/1] sch_htb: fix "too many events" situation
Date: Mon, 18 Feb 2008 02:43:48 -0800 (PST)
Message-ID: <20080218.024348.257444630.davem@davemloft.net>
References: <47B93BE8.7010905@cdi.cz>
	<20080218.001736.124204016.davem@davemloft.net>
	<47B95909.8060202@cdi.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: devik@cdi.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757082AbYBRKnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 05:43:11 -0500
In-Reply-To: <47B95909.8060202@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Devera <devik@cdi.cz>
Date: Mon, 18 Feb 2008 11:08:09 +0100

> Like
> max_jiff = jiffies+2; /* not +1 at we could be at +0.9999 now */
> while (jiffies<max_jiff) do_hard_potentionaly_long_work();
> if (more_work) schedule_to_next_jiffie();
> 
> This will keep event queue work load under 66% of system load which
> seems reasonable to me.
> 
> Would you accept such solution ?

Sure.
