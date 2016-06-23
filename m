From: David Decotigny <decot@googlers.com>
Subject: Re: [PATCH net-next V2 07/10] ethtool: Add 50G baseSR2 link mode
Date: Thu, 23 Jun 2016 09:51:24 -0700
Message-ID: <CAG88wWY-4-8FR_AH3rQb8o+PiO_wONBT1C3V8b68i5R-ACbuDw@mail.gmail.com>
References: <1466690566-14700-1-git-send-email-saeedm@mellanox.com> <1466690566-14700-8-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Ben Hutchings <bwh@kernel.org>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38479 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcFWQwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 12:52:05 -0400
Received: by mail-wm0-f44.google.com with SMTP id r201so58434905wme.1
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 09:52:05 -0700 (PDT)
In-Reply-To: <1466690566-14700-8-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 7:02 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> From: Gal Pressman <galp@mellanox.com>
>
> Add ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT bit.
>
> Signed-off-by: Gal Pressman <galp@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Cc: Ben Hutchings <bwh@kernel.org>
> Cc: David Decotigny <decot@googlers.com>
> ---
>  include/uapi/linux/ethtool.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 5f030b4..b8f38e8 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1362,6 +1362,7 @@ enum ethtool_link_mode_bit_indices {
>         ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT        = 37,
>         ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT        = 38,
>         ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT    = 39,
> +       ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT         = 40,
>
>         /* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
>          * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
> @@ -1370,7 +1371,7 @@ enum ethtool_link_mode_bit_indices {
>          */
>
>         __ETHTOOL_LINK_MODE_LAST
> -         = ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
> +         = ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
>  };
>
>  #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)     \
> --
> 2.8.0
>

Acked-By: David Decotigny <decot@googlers.com>
