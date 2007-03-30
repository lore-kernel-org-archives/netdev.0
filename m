From: David Miller <davem@davemloft.net>
Subject: Re: [NET] Change "not found" return value for rule lookup
Date: Fri, 30 Mar 2007 13:34:52 -0700 (PDT)
Message-ID: <20070330.133452.77404701.davem@davemloft.net>
References: <1175185450.1636.124.camel@quoit.chygwyn.com>
	<20070329.114306.112621613.davem@davemloft.net>
	<1175246035.1636.138.camel@quoit.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, pcaulfie@redhat.com
To: swhiteho@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51257
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753554AbXC3UfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 16:35:04 -0400
In-Reply-To: <1175246035.1636.138.camel@quoit.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <swhiteho@redhat.com>
Date: Fri, 30 Mar 2007 10:13:55 +0100

> >From 657baf6bbaa8302660d6b218149dcb5546b9b08c Mon Sep 17 00:00:00 2001
> From: Steven Whitehouse <swhiteho@redhat.com>
> Date: Fri, 30 Mar 2007 09:06:34 +0100
> Subject: [PATCH] [NET] Change "not found" return value for rule lookup
> 
> This changes the "not found" error return for the lookup
> function to -ESRCH so that it can be distinguished from
> the case where a rule or route resulting in -ENETUNREACH
> has been found during the search.
> 
> It fixes a bug where if DECnet was compiled with routing
> support, but no routes were added to the routing table,
> it was failing to fall back to endnode routing.
> 
> Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>
> Signed-off-by: Patrick Caulfield <pcaulfie@redhat.com>

Applied, thanks Steven.
