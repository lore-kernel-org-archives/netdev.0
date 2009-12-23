From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH 5/6] enic: feature add: add ethtool -c/C
	support
Date: Wed, 23 Dec 2009 18:13:19 +0000
Message-ID: <1261591999.2782.41.camel@achroite.uk.solarflarecom.com>
References: <20091222021857.30220.51795.stgit@savbu-pc100.cisco.com>
	 <20091222022147.30220.42433.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14499 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756676AbZLWSNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 13:13:23 -0500
In-Reply-To: <20091222022147.30220.42433.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-12-21 at 18:21 -0800, Scott Feldman wrote:
> From: Scott Feldman <scofeldm@cisco.com>
> 
> Only rx_usec and tx_usec options for ethtool -C are settable as those
> are the only settings that make sense to HW.  Adds driver reporting of 
> intr coalescing timer value in usec units rather than HW units.
[...]
> diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
> index 019b148..81cc68d 100644
> --- a/drivers/net/enic/enic_main.c
> +++ b/drivers/net/enic/enic_main.c
> @@ -261,7 +261,63 @@ static void enic_set_msglevel(struct net_device *netdev, u32 value)
>  	enic->msg_enable = value;
>  }
>  
> -static const struct ethtool_ops enic_ethtool_ops = {
[...]
> +static struct ethtool_ops enic_ethtool_ops = {
[...]

I don't see any reason to remove the const here.  Is that an accidental
change?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

