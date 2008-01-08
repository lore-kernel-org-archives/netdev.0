From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] ROUTE: ip_rt_dump() is unecessary slow
Date: Mon, 07 Jan 2008 21:52:53 -0800 (PST)
Message-ID: <20080107.215253.250616600.davem@davemloft.net>
References: <20080107193002.df137d57.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45616
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754119AbYAHFwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:52:55 -0500
In-Reply-To: <20080107193002.df137d57.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 7 Jan 2008 19:30:02 +0100

> I noticed "ip route list cache x.y.z.t" can be *very* slow.
> 
> While strace-ing -T it I also noticed that first part of route cache is
> fetched quite fast :
 ...
> The following patch corrects this performance/latency problem, removing quadratic behavior.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I think removing quadratic behavior is a bug fix, thus applied
to net-2.6, thanks Eric :-)
