From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 09:24:39 -0800
Message-ID: <20080201092439.7c588ef5@extreme>
References: <20080131100846.00934e25@extreme>
	<20080131185328.GD4671@one.firstfloor.org>
	<47A211A0.1040502@trash.net>
	<20080131190125.GE4671@one.firstfloor.org>
	<D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com>
	<20080131193406.GH4671@one.firstfloor.org>
	<1201847738.17656.5.camel@roma.44ansell.gdt.id.au>
	<20080201074600.GA12644@one.firstfloor.org>
	<47A2C985.30409@trash.net>
	<D5C1322C3E673F459512FB59E0DDC32904737A42@orsmsx414.amr.corp.intel.com>
	<20080201143421.GB16630@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	Andi Kleen <andi@firstfloor.org>, Glen Turner <gdt@gdt.id.au>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47657 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755781AbYBARZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 12:25:23 -0500
In-Reply-To: <20080201143421.GB16630@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 1 Feb 2008 15:34:21 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> > The TSO defer logic is based on your congestion window and current
> > window size.  So the actual frame sizes hitting your NIC attached to
> > your DSL probably aren't anywhere near 64KB, but probably more in line
> > with whatever your window size is for DSL.
> 
> DSL windows can be quite large because a lot of DSL lines have a quite
> long latency due to error correction. And with ADSL2 we have upto 16Mbit
> now.
> 
> > I think we're having more of a disagreement of what is considered the
> > "normal case" user.  If you are on a slow link, such as a DSL/cable
> > line, your TCP window/congestion window aren't going to be big enough to
> > generate large TSO's, so what is the issue?  But disabling TSO, say on a
> 
> 64k TSOs are likely even with DSL. Anyways even with smaller TSOs the
> change still makes sense because each increase makes packet scheduling
> less smooth.
> 
> -Andi

I wish there was a per-device setting for the max-size of TSO burst.


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
