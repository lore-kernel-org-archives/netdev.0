From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] sfc: add MCDI tracing
Date: Wed, 27 May 2015 13:55:23 -0400 (EDT)
Message-ID: <20150527.135523.928545676279771659.davem@davemloft.net>
References: <5565B4AF.50603@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbbE0RzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:55:25 -0400
In-Reply-To: <5565B4AF.50603@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 27 May 2015 13:12:31 +0100

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
> v4: remove patch #4, which has already been applied via sshah
> v3: add some explanations to cover letter and patch #4
> v2: avoid long lines in cover letter; fix multiline comment style

Series applied, thanks.
