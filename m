From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool]: Add strings to display Supported Ports for
 Backplane Ethernet
Date: Thu, 8 Aug 2013 20:27:30 +0200
Message-ID: <1375986450.2853.54.camel@deadeye.wl.decadent.org.uk>
References: <ac83fc1a-a967-4035-bfed-a8deff029ace@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Somnath Kotur <somnath.kotur@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6913 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab3HHS1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 14:27:34 -0400
In-Reply-To: <ac83fc1a-a967-4035-bfed-a8deff029ace@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 17:39 +0530, Somnath Kotur wrote:
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
>  ethtool.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool.c b/ethtool.c
> index 3544f0e..b24b572 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -485,6 +485,9 @@ static void dump_supported(struct ethtool_cmd *ep)
>  		fprintf(stdout, "MII ");
>  	if (mask & SUPPORTED_FIBRE)
>  		fprintf(stdout, "FIBRE ");
> +	if ((mask & SUPPORTED_10000baseKR_Full) ||
> +	    (mask & SUPPORTED_10000baseKX4_Full))
> +		fprintf(stdout, "BACKPLANE ");
>  	fprintf(stdout, "]\n");
>  
>  	dump_link_caps("Supported", "Supports", mask, 0);

No, I don't think so.  This is redundant information.  It's also
pointless to add any new port types to the advertised and supported
masks unless we have hardware that can switch port type at run-time like
some old 10M boards.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
