From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] sfc: add MCDI tracing
Date: Thu, 21 May 2015 18:52:10 -0400 (EDT)
Message-ID: <20150521.185210.860864581493237974.davem@davemloft.net>
References: <555CACF5.9060803@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbbEUWwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:52:12 -0400
In-Reply-To: <555CACF5.9060803@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 20 May 2015 16:49:09 +0100

> This patchset adds support for logging MCDI (Management-Controller-to-
>  Driver Interface) interactions between the sfc driver and a bound device,
>  to aid in debugging.
> Solarflare has a tool to decode the resulting traces and will look to
>  open-source this if there is any external interest, but the protocol is
>  already detailed in drivers/net/ethernet/sfc/mcdi_pcol.h.
> 
> v2: avoid long lines in cover letter; fix multiline comment style

All of this work to allocate the buffer, add messages to it, and dump it
to some user obtainable location duplicates existing infrastructure in
the kernel.

Please do not do this, and instead use the kernel's existing tracing
infrastructure to implement this.

I do not care how much time and effort you've already invested in your
existing tool, you should have thought about that when designing this
in the first place.
