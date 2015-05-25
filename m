From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] sfc: add MCDI tracing
Date: Mon, 25 May 2015 00:11:38 -0400 (EDT)
Message-ID: <20150525.001138.1265925235771537042.davem@davemloft.net>
References: <555F813D.8000108@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbbEYELk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 00:11:40 -0400
In-Reply-To: <555F813D.8000108@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 22 May 2015 20:19:25 +0100

> This patchset adds support for logging MCDI (Management-Controller-to-
>  Driver Interface) interactions between the sfc driver and a bound device,
>  to aid in debugging.
> Solarflare has a tool to decode the resulting traces and will look to
>  open-source this if there is any external interest, but the protocol is
>  already detailed in drivers/net/ethernet/sfc/mcdi_pcol.h.
> The logging buffer we allocate per MCDI context is a work area for
>  constructing each individual message before logging it with netif_info.
> The reason the buffer is long-lived is simply to avoid the overhead of
>  allocating and freeing it every MCDI call, since MCDIs are already known
>  to be serialised for other reasons.
> 
> --
> v3: add some explanations to cover letter and patch #4
> v2: avoid long lines in cover letter; fix multiline comment style

Patch #4 doesn't apply cleanly to net-next, please respin.

Thank you.
