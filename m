From: David Decotigny <decot@googlers.com>
Subject: Re: [ethtool PATCH v2 4/4] ethtool: Enhancing link mode bits to
 support 25G/50G/100G
Date: Mon, 27 Jun 2016 09:51:36 -0700
Message-ID: <CAG88wWZS-5hYO_yqYpPGvUdk-QFRpGAVnw=mv+mODpeo4zoV=w@mail.gmail.com>
References: <1466970307-2411-5-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bwh@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, bkenward@solarflare.com,
	daniel@iogearbox.net, Gal Pressman <galp@mellanox.com>,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	dustin@cumulusnetworks.com
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37639 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbcF0Qwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 12:52:32 -0400
Received: by mail-wm0-f49.google.com with SMTP id a66so123955260wme.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 09:52:16 -0700 (PDT)
In-Reply-To: <1466970307-2411-5-git-send-email-vidya@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 26, 2016 at 12:45 PM, Vidya Sagar Ravipati
<vidya@cumulusnetworks.com> wrote:
> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>
> Enhancing link mode bits to support 25G/50G/100G
> for supported and advertised speed mode bits
>
> Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> ---
>  ethtool.c | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
>
> diff --git a/ethtool.c b/ethtool.c
> index 1d6564e..5c3c765 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -512,6 +512,15 @@ static void init_global_link_mode_masks(void)
>                 ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT,
>                 ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT,
>                 ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_25000baseCR_Full_BIT,
> +               ETHTOOL_LINK_MODE_25000baseKR_Full_BIT,
> +               ETHTOOL_LINK_MODE_25000baseSR_Full_BIT,
> +               ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT,
> +               ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT,
> +               ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT,
> +               ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
>         };
>         static const enum ethtool_link_mode_bit_indices
>                 additional_advertised_flags_bits[] = {
> @@ -632,6 +641,24 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
>                   "56000baseSR4/Full" },
>                 { 0, ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
>                   "56000baseLR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_25000baseCR_Full_BIT,
> +                 "25000baseCR/Full" },
> +               { 0, ETHTOOL_LINK_MODE_25000baseKR_Full_BIT,
> +                 "25000baseKR/Full" },
> +               { 0, ETHTOOL_LINK_MODE_25000baseSR_Full_BIT,
> +                 "25000baseSR/Full" },
> +               { 0, ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT,
> +                 "50000baseCR2/Full" },
> +               { 0, ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT,
> +                 "50000baseKR2/Full" },
> +               { 0, ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT,
> +                 "100000baseKR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT,
> +                 "100000baseSR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT,
> +                 "100000baseCR4/Full" },
> +               { 0, ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
> +                 "100000baseLR4_ER4/Full" },
>         };
>         int indent;
>         int did1, new_line_pend, i;
> --
> 2.1.4
>

Acked-By: David Decotigny <decot@googlers.com>
