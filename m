From: davef1624@aol.com
Subject: Re: TCP congestion control for fast, short-distance networks ?
Date: Wed, 04 Apr 2007 16:15:13 -0400
Message-ID: <8C9450D169515E6-244-1CF0@FWM-D41.sysops.aol.com>
References: <20070404153911.GA32019@galon.ev-en.org>	<8C944E930D99B5D-244-E4B@FWM-D41.sysops.aol.com>	<20070404161121.GB32019@galon.ev-en.org> <20070404.125546.87742905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: davem@davemloft.net, baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-m28.mx.aol.com ([64.12.137.9]:58697 "EHLO
	imo-m28.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbXDDUPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 16:15:34 -0400
In-Reply-To: <20070404.125546.87742905.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

thanks for your help - I'll investigate turning on 802.3 level flow 
control


-----Original Message-----
From: davem@davemloft.net
To: baruch@ev-en.org
Cc: davef1624@aol.com; shemminger@linux-foundation.org; 
netdev@vger.kernel.org
Sent: Wed, 4 Apr 2007 12:55 PM
Subject: Re: TCP congestion control for fast, short-distance networks ?

  From: Baruch Even <baruch@ev-en.org>
Date: Wed, 4 Apr 2007 19:11:21 +0300

> * davef1624@aol.com <davef1624@aol.com> [070404 19:03]:
> > Thanks - so you are suggesting we enable 802.3 flow-control / 
pause-frames?
> > (it's currently disabled)
>
> I do, but do test it before you bet on it. I've never tested such a
> scenario but from my experience the lower the rtt the lesser are the
> problems that the high speed algorithms are trying to solve.

Congestion control, at the TCP level, is from one perspective
completely senseless on local high-speed networks.  The reason is that
once any kind of congestion at that level is detected, the condition
is gone by the time you could even possibly respond to it.

So with that in mind, reno is as good as anything and yes do use
pause frames.
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


________________________________________________________________________
AOL now offers free email to everyone.  Find out more about what's free 
from AOL at AOL.com.
