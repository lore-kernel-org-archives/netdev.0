From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RESEND net-next] ethtool: bring back missing comma in
 netdev features strings
Date: Thu, 12 May 2011 18:58:32 +0100
Message-ID: <1305223112.5214.39.camel@bwh-desktop>
References: <20110512164204.EC8391220061@host64.kissl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, mirqus@gmail.com
To: franco@lastsummer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25212 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758224Ab1ELR6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 13:58:36 -0400
In-Reply-To: <20110512164204.EC8391220061@host64.kissl.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 18:42 +0200, franco@lastsummer.de wrote:
> The issue was introduced in commit eed2a12f1ed9aabf.
> 
> Signed-off-by: Franco Fichtner <franco@lastsummer.de>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  net/core/ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index b6f4058..b8c2b10 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -361,7 +361,7 @@ static const char
> netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
>  	/* NETIF_F_NTUPLE */          "rx-ntuple-filter",
>  	/* NETIF_F_RXHASH */          "rx-hashing",
>  	/* NETIF_F_RXCSUM */          "rx-checksum",
> -	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy"
> +	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy",
>  	/* NETIF_F_LOOPBACK */        "loopback",
>  };
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

