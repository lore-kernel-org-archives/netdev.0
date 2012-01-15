From: "Anatoly Sivov" <mm05@mail.ru>
Subject: Re: why does skb->tstamp use getnstimeofday?
Date: Sun, 15 Jan 2012 21:55:06 +0400
Message-ID: <op.v74z14g2fzo5me@stalin>
References: <op.v74shh18fzo5me@stalin>
 <1326645750.5287.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8.mail.ru ([94.100.176.53]:59188 "EHLO smtp8.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751679Ab2AORyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 12:54:11 -0500
In-Reply-To: <1326645750.5287.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

thanks for your answer.

> monotonic time services were added later.

Yep, I understand.

> It's using this since day 0, so cannot be changed or break applications,
> which expect timeofday, not monotonic.

I missed that field tstamp is used for things other than RTT and can be  
even user-spaced with SO_TIMESTAMP.
However, timekeeper speed up/slow down (due to ntp) can seriously affect  
some congestion avoidance algorithm quality, I guess.
Am I wrong?
