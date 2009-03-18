From: David Miller <davem@davemloft.net>
Subject: Re: dnet: remove duplicated #include
Date: Wed, 18 Mar 2009 14:32:18 -0700 (PDT)
Message-ID: <20090318.143218.249024701.davem@davemloft.net>
References: <49C0E751.4010902@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weiyi.huang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35838
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751856AbZCRVcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 17:32:32 -0400
In-Reply-To: <49C0E751.4010902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huang Weiyi <weiyi.huang@gmail.com>
Date: Wed, 18 Mar 2009 20:21:37 +0800

> Removed duplicated #include in drivers/net/dnet.c.
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
> 
> diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
> index 5c347f7..8a98d40 100644
> --- a/drivers/net/dnet.c
> +++ b/drivers/net/dnet.c
> @@ -21,7 +21,6 @@
>   #include <linux/dma-mapping.h>
>   #include <linux/platform_device.h>
>   #include <linux/phy.h>
> -#include <linux/platform_device.h>
> 

This patch has been corrupted by your email client, there should
be one space before each unmodified line in the patch but
there are instead two here.

Really, for a simple one-line change like this, all of the work
of integrating the change are the important issues like this,
so please fix this up and try to get it right in the future.
