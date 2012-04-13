From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppoatm: Fix excessive queue bloat
Date: Fri, 13 Apr 2012 13:27:52 -0400 (EDT)
Message-ID: <20120413.132752.884451274918746880.davem@davemloft.net>
References: <1333914837.31812.57.camel@shinybook.infradead.org>
	<20120410102612.368b1a4f@thirdoffive.cmf.nrl.navy.mil>
	<20120413.130452.524616632667687350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org, paulus@samba.org,
	eric.dumazet@gmail.com
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab2DMRbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:31:00 -0400
In-Reply-To: <20120413.130452.524616632667687350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 13 Apr 2012 13:04:52 -0400 (EDT)

> From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
> Date: Tue, 10 Apr 2012 10:26:12 -0400
> 
>> On Sun, 08 Apr 2012 21:53:57 +0200
>> David Woodhouse <dwmw2@infradead.org> wrote:
>> 
>>> Seriously, this gets *much* easier if we just ditch the checks against
>>> sk_sndbuf. We just wake up whenever decrementing ->inflight from zero.
>>> Can I?
>> 
>> i dont know.
> 
> Please do not take this discussion private, and off of the netdev list.
> 
> Now nobody else on the list can see your response and and reply to it.

My bad, you didn't do this, my apologies.

But for some reason your replies didn't show up in the patchwork
entry for this patch, maybe your email client fumbled up the Message-Ids
because that's what patchwork uses to match things up.
