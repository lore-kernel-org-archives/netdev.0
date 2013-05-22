From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH 06/19] net/ethernet/dec/tulip/xircom_cb: Use
 module_pci_driver to register driver
Date: Tue, 21 May 2013 17:41:20 -0700
Message-ID: <CAP6odjjq_yX7JCsBnTqKYh6E_FNjYBoxnMYFDRwj6Dcou14jwA@mail.gmail.com>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
	<1369176146-19383-6-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Peter Huewe <peterhuewe@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369176146-19383-6-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[new gmail editor changed how to send plaint/text email - sorry for
multiple copies]


On Tue, May 21, 2013 at 3:42 PM, Peter Huewe <peterhuewe@gmx.de> wrote:
> Removing some boilerplate by using module_pci_driver instead of calling
> register and unregister in the otherwise empty init/exit functions.
>
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

LGTM
Reviewed-by: Grant Grundler <grundler@parisc-linux.org>

thanks,
grant

> ---
>  drivers/net/ethernet/dec/tulip/xircom_cb.c | 14 +-------------
>  1 file changed, 1 insertion(+), 13 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
> index cdbcd16..9b84cb0 100644
> --- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
> +++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
> @@ -1171,16 +1171,4 @@ investigate_write_descriptor(struct net_device *dev,
>         }
>  }
>
> -static int __init xircom_init(void)
> -{
> -       return pci_register_driver(&xircom_ops);
> -}
> -
> -static void __exit xircom_exit(void)
> -{
> -       pci_unregister_driver(&xircom_ops);
> -}
> -
> -module_init(xircom_init)
> -module_exit(xircom_exit)
> -
> +module_pci_driver(xircom_ops);
> --
> 1.8.1.5
>
