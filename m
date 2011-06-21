From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] udp:  add tracepoints for queueing skb to rcvbuf
Date: Tue, 21 Jun 2011 09:50:09 -0400
Message-ID: <20110621135009.GD16311@hmsreliant.think-freely.org>
References: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C402B96E5@USINDEVS02.corp.hds.com>
 <20110621104742.GA16311@hmsreliant.think-freely.org>
 <4123e3d3ce0192e63947178f249d3411@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satoru Moriya <satoru.moriya@hds.com>, netdev@vger.kernel.org,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47101 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab1FUNud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 09:50:33 -0400
Content-Disposition: inline
In-Reply-To: <4123e3d3ce0192e63947178f249d3411@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2011 at 01:58:27PM +0200, Hagen Paul Pfeifer wrote:
> 
> On Tue, 21 Jun 2011 06:47:43 -0400, Neil Horman wrote:
> 
> 
> 
> > I was thinking you could just trace callers of __sk_mem_schedule, but
> 
> > looking at
> 
> > it this works as well
> 
> > Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
> 
> Hey Neil,
> 
> 
> 
> since you acked the patch do you have any plans to migrate dropwatch to
> 
> use perf infrastructure and skip the netlink transport? Should be
> 
> practicable now. No kernel patch required to run dropwatch ;-)
> 
> 
I hadn't really thought about that much, but yes, I suppose I could migrate
dropwatch to export kfree_skb data via perf.  Admittedly I don't know much about
the perf api.  Do you have any pointers on its use (to save me time in figuring
out how it all works)?  If so I'll start looking into it.
Neil

> 
> 
> 
> HGN
> 
> 
> 
