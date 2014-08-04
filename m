From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: remove spurious zd1201 rule.
Date: Mon, 04 Aug 2014 15:04:37 -0700 (PDT)
Message-ID: <20140804.150437.1913700156560544044.davem@davemloft.net>
References: <20140804214744.GA1862@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pavel@ucw.cz, linville@tuxdriver.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbaHDWEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 18:04:40 -0400
In-Reply-To: <20140804214744.GA1862@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 4 Aug 2014 23:47:44 +0200

> From: Francois Romieu <romieu@fr.zoreil.com>
> 
> Leftover from 5c601d0c942f5aaf7f3cff7e08f61047d70a964e ("wireless: move
> zd1201 where it belongs").
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/Makefile | 1 -
>  1 file changed, 1 deletion(-)
> 
> It should be able to wait for 8 more years if it's a bit
> late for net-next.

:-)  Applied, thanks.

Given other similar happenings wrt. these USB rules inside of
drivers/net/Makefile, drivers/net/usb/Kconfig should just create
a CONFIG_USB_NET_DRIVERS symbol that can reduce these all down
to one.

Then:

1) Nothing to add for new USB driver.
2) Nothing to remove when USB drivers move or are delted.
