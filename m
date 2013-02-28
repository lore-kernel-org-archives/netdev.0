From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] Restore 20000baseKR2 cap display
Date: Thu, 28 Feb 2013 15:01:29 +0000
Message-ID: <1362063689.3599.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362046206-6907-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26461 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759468Ab3B1PBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 10:01:52 -0500
In-Reply-To: <1362046206-6907-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-28 at 12:10 +0200, Yaniv Rosner wrote:
> Restore the 20000baseKR2 which was removed by mistake back in June 2012.

Applied, thanks.

Ben.

> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> ---
>  ethtool.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool.c b/ethtool.c
> index 55bc082..acac32a 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -513,6 +513,7 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
>  		{ 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
>  		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
>  		{ 0, ADVERTISED_20000baseMLD2_Full, "20000baseMLD2/Full" },
> +		{ 0, ADVERTISED_20000baseKR2_Full,  "20000baseKR2/Full" },
>  		{ 0, ADVERTISED_40000baseKR4_Full,  "40000baseKR4/Full" },
>  		{ 0, ADVERTISED_40000baseCR4_Full,  "40000baseCR4/Full" },
>  		{ 0, ADVERTISED_40000baseSR4_Full,  "40000baseSR4/Full" },

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
