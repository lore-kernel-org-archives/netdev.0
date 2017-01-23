From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2/3] sh_eth: add missing EESIPR bits
Date: Mon, 23 Jan 2017 08:41:10 +0100
Message-ID: <CAMuHMdVED1D46zGkuSbpF22ZnKKjWcf50yRp-uT+LcBY_70xgA@mail.gmail.com>
References: <1636105.gp4aQxGd5K@wasted.cogentembedded.com> <3805935.iR4tgtFiHm@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36454 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAWHlM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 02:41:12 -0500
In-Reply-To: <3805935.iR4tgtFiHm@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 22, 2017 at 8:18 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Renesas SH77{34|63} manuals  describe more EESIPR bits than the current
> driver. Declare the new bits with the end goal of using the bit names
> instead of the bare numbers  for  the 'sh_eth_cpu_data::eesipr_value'
> initializers...
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>

> ---
>  drivers/net/ethernet/renesas/sh_eth.h |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>
> Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.h
> @@ -269,13 +269,17 @@ enum EESR_BIT {
>
>  /* EESIPR */
>  enum EESIPR_BIT {
> -       EESIPR_TWBIP    = 0x40000000,
> +       EESIPR_TWB1IP   = 0x80000000,
> +       EESIPR_TWBIP    = 0x40000000,   /* same as TWB0IP */

Ah, your adding it here ;-)

Gr{oetje,eeting}s,

                        Geert
