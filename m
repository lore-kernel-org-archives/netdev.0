From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Wed, 11 Nov 2009 13:33:42 -0800
Message-ID: <20091111133342.1011e16a@nehalam>
References: <200911112116.14103.opurdila@ixiacom.com>
	<20091111.112120.134023270.davem@davemloft.net>
	<200911112138.44074.opurdila@ixiacom.com>
	<20091111.124235.243348591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40354 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758931AbZKKVdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 16:33:53 -0500
In-Reply-To: <20091111.124235.243348591.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Nov 2009 12:42:35 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Wed, 11 Nov 2009 21:38:44 +0200
> 
> > I don't think we can dynamically size it at boot time since it
> > depends on the usage pattern which is impossible to determine at
> > boot time, right?
> 
> We have no idea how many sockets will be used by the system yet we
> dynamically size the socket hash tables.
> 
> Please do some research and see how we handle this elsewhere in the
> networking.

dcache also sizes hash bits at boot time on available memory.
See alloc_large_system_hash().
