From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] sfc: Handle MCDI proxy authorisation
Date: Tue, 22 Dec 2015 15:08:31 -0500 (EST)
Message-ID: <20151222.150831.895307845190172697.davem@davemloft.net>
References: <56743D6A.5020605@solarflare.com>
	<56743DB0.8030104@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933098AbbLVUId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 15:08:33 -0500
In-Reply-To: <56743DB0.8030104@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Fri, 18 Dec 2015 17:09:04 +0000

> +#ifdef DEBUG
> +		WARN_ON(1);
> +#endif

Don't do stuff like this.  Either the assertion is valid and belongs
here, or it doesn't.
