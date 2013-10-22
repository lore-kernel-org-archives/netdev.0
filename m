From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH 2/3] net: tulip: use DEFINE_PCI_DEVICE_TABLE
Date: Mon, 21 Oct 2013 20:37:40 -0700
Message-ID: <CAP6odjg8cpyf-sntLPoVBsNX_J4n2cmPSaOA=e_daTFqrC5VbQ@mail.gmail.com>
References: <000e01ceced2$a9e5d970$fdb18c50$%han@samsung.com>
	<000f01ceced2$dde772b0$99b65810$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	Grant Grundler <grundler@parisc-linux.org>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:59502 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab3JVDhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 23:37:41 -0400
Received: by mail-ob0-f170.google.com with SMTP id wp18so3312263obc.29
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 20:37:40 -0700 (PDT)
In-Reply-To: <000f01ceced2$dde772b0$99b65810$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 21, 2013 at 8:00 PM, Jingoo Han <jg1.han@samsung.com> wrote:
> This macro is used to create a struct pci_device_id array.
>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

LGTM.

Acked-by: Grant Grundler <grundler@parisc-linux.org>

> ---
>  drivers/net/ethernet/dec/tulip/de4x5.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
> index 263b92c..c05b66d 100644
> --- a/drivers/net/ethernet/dec/tulip/de4x5.c
> +++ b/drivers/net/ethernet/dec/tulip/de4x5.c
> @@ -2328,7 +2328,7 @@ static void de4x5_pci_remove(struct pci_dev *pdev)
>         pci_disable_device (pdev);
>  }
>
> -static struct pci_device_id de4x5_pci_tbl[] = {
> +static DEFINE_PCI_DEVICE_TABLE(de4x5_pci_tbl) = {
>          { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP,
>            PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
>          { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_PLUS,
> --
> 1.7.10.4
>
>
