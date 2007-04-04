From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: TCP congestion control for fast, short-distance networks ?
Date: Wed, 4 Apr 2007 10:39:44 -0700
Message-ID: <20070404103944.1b15de16@freekitty>
References: <20070403091656.769e5368@localhost.localdomain>
	<200704032113.l33LDVhp025035@expredir6.cites.uiuc.edu>
	<20070404080743.5e67245a@localhost.localdomain>
	<8C944E41FEE84B1-244-BFF@FWM-D41.sysops.aol.com>
	<20070404153911.GA32019@galon.ev-en.org>
	<8C944E930D99B5D-244-E4B@FWM-D41.sysops.aol.com>
	<20070404161121.GB32019@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davef1624@aol.com, netdev@vger.kernel.org
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49198 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbXDDRjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 13:39:51 -0400
In-Reply-To: <20070404161121.GB32019@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Apr 2007 19:11:21 +0300
Baruch Even <baruch@ev-en.org> wrote:

> * davef1624@aol.com <davef1624@aol.com> [070404 19:03]:
> > Thanks - so you are suggesting we enable 802.3 flow-control / pause-frames?
> > (it's currently disabled)
> 
> I do, but do test it before you bet on it. I've never tested such a
> scenario but from my experience the lower the rtt the lesser are the
> problems that the high speed algorithms are trying to solve.
> 
> Baruch
> 
> > 
> > -----Original Message-----
> > From: baruch@ev-en.org
> > To: davef1624@aol.com
> > Cc: shemminger@linux-foundation.org; netdev@vger.kernel.org
> > Sent: Wed, 4 Apr 2007 8:39 AM
> > Subject: Re: TCP congestion control for fast, short-distance networks ?
> > 
> >  * davef1624@aol.com <davef1624@aol.com> [070404 18:29]:
> > >Hello,
> > >
> > >We are currently using both 1 Gb & 10 Gb links, that interconnect 
> > several
> > servers that are very *local* to
> > >each other.
> > >Typical RTT times range from 0.2 ms - 0.3 ms.
> > >
> > >We are currently using TCP reno - is there a more suitable congestion 
> > control
> > algorithm for our
> > >application,
> > >especially using the 10 Gb links ?
> > >(Most of the High-Speed TCP algorithms seem suitable for large RTT,
> > long-distance networks).
> > 
> > I'm not aware of any tests for high speed links with very low RTTs, but
> > I suspect that the new algorithms will not change much, if the
> > connections you have are indeed local than the Ethernet pause mechanism
> > is more effective for the flow control you need.
> > 
> > Baruch

Pause helps (if the hardware works). But on very high speed links with low
RTT, your main source of throttling is lack of bus bandwidth on receiver.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
