From: David Miller <davem@davemloft.net>
Subject: Re: TCP congestion control for fast, short-distance networks ?
Date: Wed, 04 Apr 2007 12:55:46 -0700 (PDT)
Message-ID: <20070404.125546.87742905.davem@davemloft.net>
References: <20070404153911.GA32019@galon.ev-en.org>
	<8C944E930D99B5D-244-E4B@FWM-D41.sysops.aol.com>
	<20070404161121.GB32019@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davef1624@aol.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44909
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1766915AbXDDTzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 15:55:47 -0400
In-Reply-To: <20070404161121.GB32019@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Wed, 4 Apr 2007 19:11:21 +0300

> * davef1624@aol.com <davef1624@aol.com> [070404 19:03]:
> > Thanks - so you are suggesting we enable 802.3 flow-control / pause-frames?
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
