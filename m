From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH 10/20] uli526x: fix misspelling of current function in string
Date: Sun, 7 Dec 2014 12:48:09 -0800
Message-ID: <CAP6odjh4Gnc0uAcPTsUMFPTRj7=NYZvMgmL=Rre_kCNah+YcNg@mail.gmail.com>
References: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
	<1417980062-25151-11-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Grundler <grundler@parisc-linux.org>,
	kernel-janitors@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>, joe@perches.com,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:44279 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbaLGUsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 15:48:10 -0500
In-Reply-To: <1417980062-25151-11-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 7, 2014 at 11:20 AM, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> Replace a misspelled function name by %s and then __func__.

Patch is correct but this commit message is not. Please correct and
add my Ack-by.

cheers,
grant

> This was done using Coccinelle, including the use of Levenshtein distance,
> as proposed by Rasmus Villemoes.
>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>
> ---
> The semantic patch is difficult to summarize, but is available in the cover
> letter of this patch series.
>
>  drivers/net/ethernet/dec/tulip/uli526x.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
> index 4061f9b..1c5916b 100644
> --- a/drivers/net/ethernet/dec/tulip/uli526x.c
> +++ b/drivers/net/ethernet/dec/tulip/uli526x.c
> @@ -1837,7 +1837,7 @@ static int __init uli526x_init_module(void)
>
>  static void __exit uli526x_cleanup_module(void)
>  {
> -       ULI526X_DBUG(0, "uli526x_clean_module() ", debug);
> +       ULI526X_DBUG(0, "uli526x_cleanup_module() ", debug);
>         pci_unregister_driver(&uli526x_driver);
>  }
>
>
