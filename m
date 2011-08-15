From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: RX NFC - Convert ip address to big endian.
Date: Mon, 15 Aug 2011 17:00:16 +0100
Message-ID: <1313424016.2731.1.camel@bwh-desktop>
References: <1313422846-6550-1-git-send-email-nirmu@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nir Muchtar <nirmu@mellanox.com>
To: nirmu@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6021 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab1HOQAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 12:00:25 -0400
In-Reply-To: <1313422846-6550-1-git-send-email-nirmu@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-15 at 18:40 +0300, nirmu@dev.mellanox.co.il wrote:
> From: Nir Muchtar <nirmu@dev.mellanox.co.il>
> 
> Signed-off-by: Nir Muchtar <nirmu@mellanox.com>
> ---
> Unless there's a reason that I'm missing to why the user
> is expected to specify ip addresses in big endian format.
> 
>  rxclass.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/rxclass.c b/rxclass.c
> index b227901..98d035b 100644
> --- a/rxclass.c
> +++ b/rxclass.c
> @@ -704,7 +704,7 @@ static int rxclass_get_ulong(char *str, unsigned long long *val, int size)
>  	return 0;
>  }
>  
> -static int rxclass_get_ipv4(char *str, __be32 *val)
> +static int rxclass_get_ipv4(char *str, u32 *val)
>  {
>  	if (!inet_pton(AF_INET, str, val))
>  		return -1;
[...]

inet_pton() does the conversion to big-endian format.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

