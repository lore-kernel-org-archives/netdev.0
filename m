From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: don't BUG_ON efx->max_channels == 0 in probe
Date: Mon, 03 Nov 2014 15:58:21 -0500 (EST)
Message-ID: <20141103.155821.1814140850277209257.davem@davemloft.net>
References: <alpine.LFD.2.03.1411031409100.24185@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sshah@solarflare.com,
	linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbaKCU6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 15:58:23 -0500
In-Reply-To: <alpine.LFD.2.03.1411031409100.24185@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Mon, 3 Nov 2014 14:14:35 +0000

> efx_ef10_probe() was BUGging out if the BAR2 size was 0.  This is
>  unnecessarily violent; instead we should just fail to probe the device.
> Kept a WARN_ON as this problem indicates a broken or misconfigured NIC.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied, thanks.
