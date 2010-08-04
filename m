From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: can TCP socket send buffer be over used?
Date: Wed, 4 Aug 2010 10:21:33 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008041018380.19930@uplift.swm.pp.se>
References: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>  <alpine.DEB.1.10.1008040932030.19930@uplift.swm.pp.se> <AANLkTikJvTvzuPhJ59RNcCGXPWP4EidaHx0=oUK8jjiy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Jack Zhang <jack.zhang2011@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:40392 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751487Ab0HDIVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 04:21:34 -0400
In-Reply-To: <AANLkTikJvTvzuPhJ59RNcCGXPWP4EidaHx0=oUK8jjiy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Aug 2010, Jack Zhang wrote:

> Hi Mikael,
>
> Thanks for your reply. I'll definitely try that.
>
> Quick question though... the link I use in my test does not have any
> packet loss (it's a straight through cable between two PCs)... in this
> case, would TCP congestion window size affect the result at all?

I always mix up the different TCP windows, but I mean the windows size the 
sender will use max for the session. I'm not sure this is the same as the 
buffer you're tuning with your userspace option.

An easy test would be for you to set the userspace option to 64k, test 
what speeds you get, then you turn off window scaling in /proc, and try 
again. If you get wildly different results here (turning off window 
scaling limits the window to 64k) then the buffer you're tuning doesn't do 
what you think it does.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
