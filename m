From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 04/13] net: ethernet: aquantia: Using
 module_pci_driver.
Date: Wed, 15 Feb 2017 21:57:11 +0100
Message-ID: <905ab39c-bb29-9526-a5b9-1d8a14a5d25d@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <cc1d90b68667d8cedb95bc255df81bb6ecbf9586.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:60164 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751994AbdBOU5V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:57:21 -0500
In-Reply-To: <cc1d90b68667d8cedb95bc255df81bb6ecbf9586.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2017 21:01, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
>
> Remove boilerplate code by using macro module_pci_driver.
>
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_main.c | 20 +-------------------
>  1 file changed, 1 insertion(+), 19 deletions(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> index e5539c8..f7513cb 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> @@ -250,22 +250,4 @@ static struct pci_driver aq_pci_ops = {
>  	.resume = aq_pci_resume,
>  };
>
> -static int __init aq_module_init(void)
> -{
> -	int err = 0;
> -
> -	err = pci_register_driver(&aq_pci_ops);
> -	if (err < 0)
> -		goto err_exit;
> -
> -err_exit:
> -	return err;
> -}
> -
> -static void __exit aq_module_exit(void)
> -{
> -	pci_unregister_driver(&aq_pci_ops);
> -}
> -
> -module_init(aq_module_init);
> -module_exit(aq_module_exit);
> +module_pci_driver(aq_pci_ops);
>

Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Regards,
Lino
