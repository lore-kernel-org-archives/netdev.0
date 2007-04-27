From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH repost] netpoll: trapping fix/cleanup
Date: Fri, 27 Apr 2007 15:27:13 -0500
Message-ID: <20070427202713.GS11115@waste.org>
References: <200704272344.00410.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:58909 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757219AbXD0UkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 16:40:08 -0400
Content-Disposition: inline
In-Reply-To: <200704272344.00410.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 27, 2007 at 11:44:00PM +0400, Sergei Shtylyov wrote:
> CONFIG_NETPOLL_TRAP causes the TX queue controls to be completely bypassed in
> the netpoll's "trapped" mode which easily causes overflows in the drivers with
> short TX queues (most notably, in 8139too with its 4-deep queue).
> Make this option more sensible by only bypassing TX softirq wakeup and remove
> CONFIG_NETPOLL_RX option completely since there is *no* code depending on it.

You've got two unrelated patches here, so that's an automatic NAK.

I suppose we can kill the config option.

What did you test the NETPOLL_TRAP test with?

-- 
Mathematics is the supreme nostalgia of our time.
