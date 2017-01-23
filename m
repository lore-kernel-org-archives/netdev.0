From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/3] sh_eth: rename EESIPR bits
Date: Mon, 23 Jan 2017 08:39:35 +0100
Message-ID: <CAMuHMdVS4C37FGtB+eCytz-=aXSjGB7vYGUCnLG=rKN0L1io7g@mail.gmail.com>
References: <1636105.gp4aQxGd5K@wasted.cogentembedded.com> <6851530.HAKW22qnWH@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36115 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAWHjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 02:39:36 -0500
In-Reply-To: <6851530.HAKW22qnWH@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Sun, Jan 22, 2017 at 8:18 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Since the  commit  b0ca2a21f769 ("sh_eth: Add support of SH7763 to sh_eth")
> the *enum* declaring the EESIPR bits (interrupt mask) went out of sync with
> the *enum* declaring the EESR bits (interrupt status) WRT  bit naming  and
> formatting. I'd like to restore the consistency by using EESIPR as the bit
> name prefix, renaming the *enum* to EESIPR_BIT, and (finally) renaming the
> bits according to the available  Renesas SH77{34|63} manuals...

Which versions of the SH77{34|63} manuals did you use?
Several registers are called slightly different in mine, and also in my
r8a7740 manual.

> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.h
> @@ -268,19 +268,29 @@ enum EESR_BIT {
>                                  EESR_TFE | EESR_TDE)
>
>  /* EESIPR */
> -enum DMAC_IM_BIT {
> -       DMAC_M_TWB = 0x40000000, DMAC_M_TABT = 0x04000000,
> -       DMAC_M_RABT = 0x02000000,
> -       DMAC_M_RFRMER = 0x01000000, DMAC_M_ADF = 0x00800000,
> -       DMAC_M_ECI = 0x00400000, DMAC_M_FTC = 0x00200000,
> -       DMAC_M_TDE = 0x00100000, DMAC_M_TFE = 0x00080000,
> -       DMAC_M_FRC = 0x00040000, DMAC_M_RDE = 0x00020000,
> -       DMAC_M_RFE = 0x00010000, DMAC_M_TINT4 = 0x00000800,
> -       DMAC_M_TINT3 = 0x00000400, DMAC_M_TINT2 = 0x00000200,
> -       DMAC_M_TINT1 = 0x00000100, DMAC_M_RINT8 = 0x00000080,
> -       DMAC_M_RINT5 = 0x00000010, DMAC_M_RINT4 = 0x00000008,
> -       DMAC_M_RINT3 = 0x00000004, DMAC_M_RINT2 = 0x00000002,
> -       DMAC_M_RINT1 = 0x00000001,
> +enum EESIPR_BIT {
> +       EESIPR_TWBIP    = 0x40000000,

TWBIP is actually two bits in my manual: TWB1IP and TWB0IP

> +       EESIPR_ADEIP    = 0x00800000,

Nonexistent bit in my manual.

> +       EESIPR_CNDIP    = 0x00000800,

Nonexistent bit in my manual.

Gr{oetje,eeting}s,

                        Geert
