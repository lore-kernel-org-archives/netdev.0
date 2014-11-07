From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] stmmac: remove custom implementation of
 print_hex_dump()
Date: Fri, 07 Nov 2014 12:20:53 -0500 (EST)
Message-ID: <20141107.122053.864393917282057137.davem@davemloft.net>
References: <1415371992-12915-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, peppe.cavallaro@st.com, netdev@vger.kernel.org,
	vbridgers2013@gmail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaKGRU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 12:20:56 -0500
In-Reply-To: <1415371992-12915-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri,  7 Nov 2014 16:53:12 +0200

> There is a kernel helper to dump buffers in a hexdecimal format. This patch
> substitutes the open coded function by calling that helper.
> 
> The output is slightly changed:
>  - no lead space
>  - ASCII part will be printed along with the dump
>  - offset is longer than 3 characters (now 8)
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
> Since v1:
> - address Joe's comments
> - describe output change
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 10 ++--------

Applied to net-next, thanks.
