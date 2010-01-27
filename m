From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2.6.33-rc5] drivers/net: ks8851_mll ethernet network
	driver
Date: Wed, 27 Jan 2010 16:28:33 +0000
Message-ID: <1264609713.2839.3.camel@achroite.uk.solarflarecom.com>
References: <C43529A246480145B0A6D0234BDB0F0D02129C@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Choi, David" <David.Choi@Micrel.Com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42254 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800Ab0A0Q2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 11:28:36 -0500
In-Reply-To: <C43529A246480145B0A6D0234BDB0F0D02129C@MELANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-01-27 at 08:03 -0800, Choi, David wrote:
> Hello David Miller,
> 
> I fix a bug in ks8851_mll driver, which has existed since 2.6.32-rc6.
> 
> From : David J. Choi <david.choi@micrel.com>
> 
> Fix a bug that the data pointers in the interrupt handler are set wrong, which is related with the 5th parameter of request_irq().   
> 
> Signed-off-by : David J. Choi <david.choi@micrel.com>

This should go to stable as well since the driver will be useless
without this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

