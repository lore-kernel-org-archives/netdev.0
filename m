From: David Miller <davem@davemloft.net>
Subject: Re: ip_rt_bug questions.
Date: Mon, 18 Apr 2011 14:49:09 -0700 (PDT)
Message-ID: <20110418.144909.52209035.davem@davemloft.net>
References: <20110418214809.GA17443@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43208
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751494Ab1DRVtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 17:49:43 -0400
In-Reply-To: <20110418214809.GA17443@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 18 Apr 2011 17:48:10 -0400

> I managed to trigger this today..
> 
> ip_rt_bug: 0.0.0.0 -> 255.255.255.255, ?
> 
> if this is useful in some way, maybe it should be enhanced
> to print out something else, like a backtrace ?
> 
> Also, should it be a printk_ratelimit() ? Or is there
> ratelimiting done elsewhere in the routing code ?
> 
> or should it just be silenced, leaving just the kfree_skb ?

It's a very serious issue, it means we used an input route for
packet output.

Kernel version and what you were doing to trigger this?
