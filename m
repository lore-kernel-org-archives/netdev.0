From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 05/36] net: ethernet: 8390: remove unnecessary
 platform_set_drvdata()
Date: Tue, 28 May 2013 13:53:45 +0900
Message-ID: <000001ce5b5f$55a63620$00f2a260$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:11444 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab3E1Exr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 00:53:47 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MNH002BRS9M3CJ0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 28 May 2013 13:53:46 +0900 (KST)
References: 
In-reply-to: 
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, May 07, 2013 1:19 PM, Jingoo Han wrote:
> 
> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Hi David,

I will squash everything down into one patch with the ACKs,
and send it again.

Best regards,
Jingoo Han


> ---
>  drivers/net/ethernet/8390/ne.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
> index 47618e5..b2e8405 100644
> --- a/drivers/net/ethernet/8390/ne.c
> +++ b/drivers/net/ethernet/8390/ne.c
> @@ -849,7 +849,6 @@ static int ne_drv_remove(struct platform_device *pdev)
>  		free_irq(dev->irq, dev);
>  		release_region(dev->base_addr, NE_IO_EXTENT);
>  		free_netdev(dev);
> -		platform_set_drvdata(pdev, NULL);
>  	}
>  	return 0;
>  }
> --
> 1.7.2.5
