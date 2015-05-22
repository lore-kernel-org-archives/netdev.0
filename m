From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] sfc: add MCDI tracing
Date: Fri, 22 May 2015 15:03:49 -0400 (EDT)
Message-ID: <20150522.150349.396711490885065669.davem@davemloft.net>
References: <555CACF5.9060803@solarflare.com>
	<20150521.185210.860864581493237974.davem@davemloft.net>
	<555F420A.2040104@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757213AbbEVTDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 15:03:51 -0400
In-Reply-To: <555F420A.2040104@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 22 May 2015 15:49:46 +0100

> On 21/05/15 23:52, David Miller wrote:
>> All of this work to allocate the buffer, add messages to it, and dump it
>> to some user obtainable location duplicates existing infrastructure in
>> the kernel.
>> Please do not do this, and instead use the kernel's existing tracing
>> infrastructure to implement this.
> 
> The logging_buffer we allocate isn't there to store _messages_ for later
> dumping, it's a work area for constructing a _single_ message, which is
> then merely written to the system log with netif_info.  Thus, I don't see
> how it would make much difference if we used (say) ftrace instead of
> netif_info to ship the events to userspace.
> The reason the buffer is long-lived is simply to avoid the overhead of
> allocating and freeing it every MCDI call, since MCDIs are already known
> to be serialised for other reasons.
> Can you please further explain your objection and what you'd prefer us to
> do?

Ok fair enough, please repost your series, thanks.
