From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: fixes for PHY_RESUMING state changes
Date: Thu, 02 Jul 2009 13:17:53 -0700 (PDT)
Message-ID: <20090702.131753.201104772.davem@davemloft.net>
References: <1246489234.26353.60.camel@rhino>
	<3253A2AC-9D19-4B02-8526-0D460C6E409E@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfarnsworth@mvista.com, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757499AbZGBURr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 16:17:47 -0400
In-Reply-To: <3253A2AC-9D19-4B02-8526-0D460C6E409E@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Wed, 1 Jul 2009 19:34:24 -0500

> 
> On Jul 1, 2009, at 6:00 PM, Wade Farnsworth wrote:
> 
>> The PHY_HALTED state disables phydev->link, but the link will not be
>> updated upon entering PHY_RESUMING.  Add a call to phy_read_status()
>> to
>> update the link before entering PHY_RUNNING.  If the link is not up at
>> this point, enter the PHY_NOLINK state instead.
>>
>> Also, when transitioning from PHY_RESUMING to PHY_RUNNING, calls to
>> netif_carrier_on() and phydev->adjust_link() are missing.  Add the
>> calls
>> similar to the other transitions to PHY_RUNNING.
>>
>> Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>
> 
> Acked-by: Andy Fleming <afleming@freescale.com>

Applied.
