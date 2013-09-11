From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 20/52] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 22:19:33 +0400
Message-ID: <5230B435.2050908@cogentembedded.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com> <005e01ceaec2$23e32420$6ba96c60$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:62065 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755331Ab3IKSTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:19:32 -0400
Received: by mail-lb0-f176.google.com with SMTP id y6so7636280lbh.7
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:19:31 -0700 (PDT)
In-Reply-To: <005e01ceaec2$23e32420$6ba96c60$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/11/2013 11:40 AM, Jingoo Han wrote:

> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.

> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> ---
>   drivers/net/ethernet/fealnx.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
> index c706b7a..99194d1 100644
> --- a/drivers/net/ethernet/fealnx.c
> +++ b/drivers/net/ethernet/fealnx.c
> @@ -699,9 +699,9 @@ static void fealnx_remove_one(struct pci_dev *pdev)
>   		pci_iounmap(pdev, np->mem);
>   		free_netdev(dev);
>   		pci_release_regions(pdev);
> -		pci_set_drvdata(pdev, NULL);
> -	} else
> +	} else {
>   		printk(KERN_ERR "fealnx: remove for unknown device\n");
> +	}

    No "drove-by" coding style fixes, please.

WBR, Sergei
