From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: FW: [PATCH ethtool] ethtool: Add string to display support for
 KR PHY
Date: Thu, 21 Mar 2013 18:15:56 +0000
Message-ID: <1363889756.2736.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <1360659168-14346-1-git-send-email-vasundhara.volam@emulex.com>
	 <f30e7788-1920-426f-88c2-afadac2cee75@CMEXHTCAS2.ad.emulex.com>
	 <7C0C8AF2F9AEF149AE37E5CA3E2101D3216EDBB7@CMEXMB2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Vasundhara, Volam" <Vasundhara.Volam@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:18667 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362Ab3CUSP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 14:15:59 -0400
In-Reply-To: <7C0C8AF2F9AEF149AE37E5CA3E2101D3216EDBB7@CMEXMB2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-13 at 09:29 +0000, Vasundhara, Volam wrote:
> Please apply.

Sorry for the delay; I've applied this now.

Ben.

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Vasundhara, Volam
> Sent: Tuesday, February 12, 2013 3:16 PM
> To: bhutchings@solarflare.com
> Cc: netdev@vger.kernel.org; Vasundhara, Volam
> Subject: [PATCH ethtool] ethtool: Add string to display support for KR PHY
> 
> 
> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
> ---
>  ethtool.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/ethtool.c b/ethtool.c
> index 55bc082..205f574 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -512,6 +512,7 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
>  		{ 0, ADVERTISED_2500baseX_Full,     "2500baseX/Full" },
>  		{ 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
>  		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
> +		{ 0, ADVERTISED_10000baseKR_Full,   "10000baseKR/Full" },
>  		{ 0, ADVERTISED_20000baseMLD2_Full, "20000baseMLD2/Full" },
>  		{ 0, ADVERTISED_40000baseKR4_Full,  "40000baseKR4/Full" },
>  		{ 0, ADVERTISED_40000baseCR4_Full,  "40000baseCR4/Full" },
> --
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
