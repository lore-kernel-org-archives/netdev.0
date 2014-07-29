From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: Use __iowrite64_copy instead of a
 slightly different local function
Date: Tue, 29 Jul 2014 15:30:48 -0700 (PDT)
Message-ID: <20140729.153048.1378087192291832153.davem@davemloft.net>
References: <1406427279.29010.139.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sshah@solarflare.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170AbaG2Wat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 18:30:49 -0400
In-Reply-To: <1406427279.29010.139.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 27 Jul 2014 03:14:39 +0100

> __iowrite64_copy() isn't quite the same as efx_memcpy_64(), but
> it looks close enough:
> 
> - The length is in units of qwords not bytes
> - It never byte-swaps, but that doesn't make a difference now as PIO
>   is only enabled for x86_64
> - It doesn't include any memory barriers, but that's OK as there is a
>   barrier just before pushing the doorbell
> - mlx4_en uses it for the same purpose
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied, thanks.
