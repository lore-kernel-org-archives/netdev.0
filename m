From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] New driver "sfc" for Solarstorm SFC4000 controller
 (try #8)
Date: Sun, 23 Mar 2008 22:39:42 -0700 (PDT)
Message-ID: <20080323.223942.08475349.davem@davemloft.net>
References: <20080312012102.GB24160@solarflare.com>
	<20080312012538.GH24160@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42761
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752260AbYCXFjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:39:43 -0400
In-Reply-To: <20080312012538.GH24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 12 Mar 2008 01:25:39 +0000

> +static void efx_ethtool_get_stats(struct net_device *net_dev,
> +				  struct ethtool_stats *stats
> +				  __attribute__ ((unused)), u64 *data)
> +{

The unused tag should be necessary for function arguments.

> +	unsigned long flags __attribute__ ((unused));

Delete.
