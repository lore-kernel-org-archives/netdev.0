From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: Re: [PATCH -next] net: wan: slic_ds26522: Use module_spi_driver to
 simplify the code
Date: Mon, 17 Oct 2016 17:38:02 -0300
Message-ID: <4f9d6820-d3c4-ea90-8b3a-b6d4f5911580@osg.samsung.com>
References: <1476715845-27691-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>, Zhao Qiang <qiang.zhao@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:37807
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932306AbcJQUiL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 16:38:11 -0400
In-Reply-To: <1476715845-27691-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Wei,

On 10/17/2016 11:50 AM, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> module_spi_driver() makes the code simpler by eliminating
> boilerplate code.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> ---
>  drivers/net/wan/slic_ds26522.c | 13 +------------
>  1 file changed, 1 insertion(+), 12 deletions(-)
> 
> diff --git a/drivers/net/wan/slic_ds26522.c b/drivers/net/wan/slic_ds26522.c
> index b776a0a..8f782f1 100644
> --- a/drivers/net/wan/slic_ds26522.c
> +++ b/drivers/net/wan/slic_ds26522.c
> @@ -249,15 +249,4 @@ static struct spi_driver slic_ds26522_driver = {
>  	.id_table = slic_ds26522_id,
>  };
>  
> -static int __init slic_ds26522_init(void)
> -{
> -	return spi_register_driver(&slic_ds26522_driver);
> -}
> -
> -static void __exit slic_ds26522_exit(void)
> -{
> -	spi_unregister_driver(&slic_ds26522_driver);
> -}
> -
> -module_init(slic_ds26522_init);
> -module_exit(slic_ds26522_exit);
> +module_spi_driver(slic_ds26522_driver);
> 

Reviewed-by: Javier Martinez Canillas <javier@osg.samsung.com>

Best regards,
-- 
Javier Martinez Canillas
Open Source Group
Samsung Research America
