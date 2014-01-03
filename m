From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2] sh_eth: coding style fixes
Date: Fri, 3 Jan 2014 13:04:33 +0100
Message-ID: <CAMuHMdX-0ZkGqewJ91CN7xWpmzmv-6XSXd0j_g0yT6VNRPPKZg@mail.gmail.com>
References: <201401031552.22847.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:37486 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaACMEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 07:04:33 -0500
In-Reply-To: <201401031552.22847.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 3, 2014 at 1:52 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> @@ -2739,7 +2734,7 @@ static int sh_eth_drv_probe(struct platf
>
>         /* print device information */
>         pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
> -              (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
> +               (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);

Hint for the next patch: use 0x%lx and kill the cast.

Thx! ;-)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
