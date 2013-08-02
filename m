From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] ethtool: Add string/define to display Port Type
 for Backplane Ethernet
Date: Fri, 2 Aug 2013 14:40:55 +0200
Message-ID: <1375447255.11783.9.camel@deadeye.wl.decadent.org.uk>
References: <4f5874f0-845c-429e-8c14-fc948ed7a2e8@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Somnath Kotur <somnath.kotur@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56716 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476Ab3HBMk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 08:40:59 -0400
In-Reply-To: <4f5874f0-845c-429e-8c14-fc948ed7a2e8@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-02 at 10:36 +0530, Somnath Kotur wrote:
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
>  ethtool-copy.h |    1 +
>  ethtool.c      |    3 +++
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index b5515c2..33ff7d3 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -989,6 +989,7 @@ enum ethtool_sfeatures_retval_bits {
>  #define PORT_FIBRE		0x03
>  #define PORT_BNC		0x04
>  #define PORT_DA			0x05
> +#define PORT_BACKPLANE		0x06
>  #define PORT_NONE		0xef
>  #define PORT_OTHER		0xff
>  

Needs to be updated in the kernel first.

> diff --git a/ethtool.c b/ethtool.c
> index b24b572..4db42b3 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -625,6 +625,9 @@ static int dump_ecmd(struct ethtool_cmd *ep)
>  	case PORT_DA:
>  		fprintf(stdout, "Direct Attach Copper\n");
>  		break;
> +	case PORT_BACKPLANE:
> +		fprintf(stdout, "BackPlane\n");
> +		break;

Why the capital P?  I don't think I've seen it written that way before.

Ben.

>  	case PORT_NONE:
>  		fprintf(stdout, "None\n");
>  		break;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
