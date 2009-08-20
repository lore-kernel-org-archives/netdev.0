From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC][PATCH][v4] net/ethtool: Add support for the ethtool
	feature to flash firmware image from a specified file.
Date: Thu, 20 Aug 2009 18:24:32 +0100
Message-ID: <1250789072.2779.1.camel@achroite>
References: <20090820171631.GA19783@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:33477 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754953AbZHTRYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 13:24:36 -0400
In-Reply-To: <20090820171631.GA19783@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-20 at 22:46 +0530, Ajit Khaparde wrote:
[...]
> @@ -489,6 +501,7 @@ struct ethtool_ops {
>  	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
>  	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
>  	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
> +	int     (*flash_device)(struct net_device *, u8 *);
[...]

The second parameter type should be struct ethtool_flash * not u8 *.
The compiler warning should make this easy to spot...

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

