From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wl12xx: fix compilation error when CONFIG_PM is not set
Date: Wed, 18 May 2011 17:00:10 -0400 (EDT)
Message-ID: <20110518.170010.1886397881423466575.davem@davemloft.net>
References: <1305751102.12586.1546.camel@cumari>
	<1305751537-27533-1-git-send-email-coelho@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, eliad@wizery.com, ido@wizery.com
To: coelho@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531Ab1ERVBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 17:01:21 -0400
In-Reply-To: <1305751537-27533-1-git-send-email-coelho@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luciano Coelho <coelho@ti.com>
Date: Wed, 18 May 2011 23:45:37 +0300

> There was a compilation error when PM is not enabled:
> 
>   CC [M]  drivers/net/wireless/wl12xx/main.o
> drivers/net/wireless/wl12xx/main.c:3653: error: unknown field 'suspend' specified in initializer
> drivers/net/wireless/wl12xx/main.c:3653: warning: initialization from incompatible pointer type
> drivers/net/wireless/wl12xx/main.c:3654: error: unknown field 'resume' specified in initializer
> drivers/net/wireless/wl12xx/main.c:3654: warning: initialization from incompatible pointer type
> 
> Fix this by adding #ifdef's in the appropriate places.
> 
> Cc: Eliad Peller <eliad@wizery.com>
> Signed-off-by: Luciano Coelho <coelho@ti.com>

Applied, thanks.
