From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Don't flush n-tuple list from ethtool_reset()
Date: Wed, 17 Feb 2010 13:39:34 -0800 (PST)
Message-ID: <20100217.133934.143869560.davem@davemloft.net>
References: <1266434814.2090.6.camel@achroite.uk.solarflarecom.com>
	<Pine.WNT.4.64.1002171128350.7212@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754848Ab0BQVjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:39:19 -0500
In-Reply-To: <Pine.WNT.4.64.1002171128350.7212@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Wed, 17 Feb 2010 11:29:33 -0800 (Pacific Standard Time)

> On Wed, 17 Feb 2010, Ben Hutchings wrote:
> 
>> The n-tuple list should be flushed if and only if the ETH_RESET_FILTER
>> flag is set and the driver is able to reset filtering/flow direction
>> hardware without also resetting a component whose flag is not set.
>> This test is best left to the driver.
>> 
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Yes, this was the intent.  Thanks for cleaning this bit up in the ethtool 
> core.

Patch applied, thanks everyone.
