From: davef1624@aol.com
Subject: Re: TCP congestion control for fast, short-distance networks ?
Date: Wed, 04 Apr 2007 11:58:15 -0400
Message-ID: <8C944E930D99B5D-244-E4B@FWM-D41.sysops.aol.com>
References: <20070403091656.769e5368@localhost.localdomain> <200704032113.l33LDVhp025035@expredir6.cites.uiuc.edu> <20070404080743.5e67245a@localhost.localdomain> <8C944E41FEE84B1-244-BFF@FWM-D41.sysops.aol.com> <20070404153911.GA32019@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-m20.mx.aol.com ([64.12.137.1]:63734 "EHLO
	imo-m20.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992982AbXDDQDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 12:03:39 -0400
In-Reply-To: <20070404153911.GA32019@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks - so you are suggesting we enable 802.3 flow-control / 
pause-frames?
(it's currently disabled)

-----Original Message-----
From: baruch@ev-en.org
To: davef1624@aol.com
Cc: shemminger@linux-foundation.org; netdev@vger.kernel.org
Sent: Wed, 4 Apr 2007 8:39 AM
Subject: Re: TCP congestion control for fast, short-distance networks ?

  * davef1624@aol.com <davef1624@aol.com> [070404 18:29]:
> Hello,
>
> We are currently using both 1 Gb & 10 Gb links, that interconnect 
several
servers that are very *local* to
> each other.
> Typical RTT times range from 0.2 ms - 0.3 ms.
>
> We are currently using TCP reno - is there a more suitable congestion 
control
algorithm for our
> application,
> especially using the 10 Gb links ?
> (Most of the High-Speed TCP algorithms seem suitable for large RTT,
long-distance networks).

I'm not aware of any tests for high speed links with very low RTTs, but
I suspect that the new algorithms will not change much, if the
connections you have are indeed local than the Ethernet pause mechanism
is more effective for the flow control you need.

Baruch
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


________________________________________________________________________
AOL now offers free email to everyone.  Find out more about what's free 
from AOL at AOL.com.
