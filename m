From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.33-rc5] drivers/net: ks8851_mll ethernet network
 driver
Date: Thu, 28 Jan 2010 05:59:37 -0800 (PST)
Message-ID: <20100128.055937.238598283.davem@davemloft.net>
References: <C43529A246480145B0A6D0234BDB0F0D02129C@MELANITE.micrel.com>
	<1264609713.2839.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Choi@Micrel.Com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756248Ab0A1N7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 08:59:25 -0500
In-Reply-To: <1264609713.2839.3.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Jan 2010 16:28:33 +0000

> On Wed, 2010-01-27 at 08:03 -0800, Choi, David wrote:
>> Hello David Miller,
>> 
>> I fix a bug in ks8851_mll driver, which has existed since 2.6.32-rc6.
>> 
>> From : David J. Choi <david.choi@micrel.com>
>> 
>> Fix a bug that the data pointers in the interrupt handler are set wrong, which is related with the 5th parameter of request_irq().   
>> 
>> Signed-off-by : David J. Choi <david.choi@micrel.com>
> 
> This should go to stable as well since the driver will be useless
> without this.

Applied and queued to -stable.
