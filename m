From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [ethtool PATCH v3 4/4] ethtool: Enhancing link mode bits to
 support 25G/50G/100G
Date: Mon, 22 Aug 2016 15:27:30 -0400
Message-ID: <20160822192729.GC2628@tuxdriver.com>
References: <1471823044-5165-5-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, decot@googlers.com,
        bkenward@solarflare.com, daniel@iogearbox.net, galp@mellanox.com,
        roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
        dustin@cumulusnetworks.com, ben@decadent.org.uk
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36912 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752458AbcHVTag (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 15:30:36 -0400
Content-Disposition: inline
In-Reply-To: <1471823044-5165-5-git-send-email-vidya@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 21, 2016 at 04:44:04PM -0700, Vidya Sagar Ravipati wrote:
> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> 
> Enhancing link mode bits to support 25G/50G/100G
> for supported and advertised speed mode bits
> 
> Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> Acked-By: David Decotigny <decot@googlers.com>
> ---
>  ethtool.c | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/ethtool.c b/ethtool.c
> index 1d6564e..5c3c765 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -512,6 +512,15 @@ static void init_global_link_mode_masks(void)
>  		ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT,
>  		ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT,
>  		ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
> +		ETHTOOL_LINK_MODE_25000baseCR_Full_BIT,
> +		ETHTOOL_LINK_MODE_25000baseKR_Full_BIT,
> +		ETHTOOL_LINK_MODE_25000baseSR_Full_BIT,
> +		ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT,
> +		ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT,
> +		ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT,
> +		ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT,
> +		ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT,
> +		ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
>  	};
>  	static const enum ethtool_link_mode_bit_indices
>  		additional_advertised_flags_bits[] = {
> @@ -632,6 +641,24 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
>  		  "56000baseSR4/Full" },
>  		{ 0, ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
>  		  "56000baseLR4/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_25000baseCR_Full_BIT,
> +		  "25000baseCR/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_25000baseKR_Full_BIT,
> +		  "25000baseKR/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_25000baseSR_Full_BIT,
> +		  "25000baseSR/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT,
> +		  "50000baseCR2/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT,
> +		  "50000baseKR2/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT,
> +		  "100000baseKR4/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT,
> +		  "100000baseSR4/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT,
> +		  "100000baseCR4/Full" },
> +		{ 0, ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
> +		  "100000baseLR4_ER4/Full" },
>  	};
>  	int indent;
>  	int did1, new_line_pend, i;

If my other comment wasn't clear, this is the patch I
to which I was suggesting that you could add support for
ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
