From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH 11/19] net/ethernet/broadcom/tg3: Use
 module_pci_driver to register driver
Date: Tue, 21 May 2013 17:22:48 -0700
Message-ID: <519C0FD8.80705@broadcom.com>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
 <1369177096-19674-11-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael Chan" <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Peter Huewe" <peterhuewe@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369177096-19674-11-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/21/2013 03:58 PM, Peter Huewe wrote:
> Removing some boilerplate by using module_pci_driver instead of calling
> register and unregister in the otherwise empty init/exit functions.
>
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
> ---
>   drivers/net/ethernet/broadcom/tg3.c | 13 +------------
>   1 file changed, 1 insertion(+), 12 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index fb06aa1..4f0e3fe 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -17804,15 +17804,4 @@ static struct pci_driver tg3_driver = {
>   	.driver.pm	= &tg3_pm_ops,
>   };
>
> -static int __init tg3_init(void)
> -{
> -	return pci_register_driver(&tg3_driver);
> -}
> -
> -static void __exit tg3_cleanup(void)
> -{
> -	pci_unregister_driver(&tg3_driver);
> -}
> -
> -module_init(tg3_init);
> -module_exit(tg3_cleanup);
> +module_pci_driver(tg3_driver);
>

Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>
